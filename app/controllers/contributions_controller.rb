require 'amazon/fps/amazon_logger'
require 'amazon/fps/amazon_validator'

ERROR_STRING = "An error occurred with your contribution. Please try again."

class ContributionsController < ApplicationController
  before_filter :authenticate_user!, only: [ :new, :create, :save, :edit, :update, :update_save, :destroy ]

  cache_sweeper :contribution_sweeper

  load_and_authorize_resource except: [:new, :create, :save, :edit, :update_save]
  skip_authorization_check only: [:save, :edit, :update_save]

  def new
    @project = Project.find_by_name params[:project].gsub(/-/, ' ')
    @contribution = @project.contributions.new
    authorize! :create, @contribution
    validate_project @project
  end

  def create
    @contribution = prepare_contribution
    authorize! :create, @contribution
    validate_project @contribution.project

    if @contribution.valid? && @contribution.project.end_date >= Date.today
      #Worth considering alternatives if the performance on this is bad
      #E.g. memcached, writing to the DB and marking record incomplete

      if !@contribution.save
        return redirect_to @contribution.project, alert: "An error occured while submitting your contribution. Please try again."
      end
      session[:contribution_id] = @contribution.id
      log_user_action :create
      redirect_to AmazonFlexPay.multi_use_pipeline(
        UUIDTools::UUID.random_create.to_s,
        save_contribution_url,
        recipient_token_list: @contribution.project.payment_account_id,
        global_amount_limit: @contribution.amount
      )
    else
      render action: :new, alert: "Sorry, this project is no longer taking contributions."
    end
  end

  #Return URL from payment gateway
  def save
    if session[:contribution_id].nil?
      return redirect_to root_path, alert: ERROR_STRING
    end
    @contribution = Contribution.find(session[:contribution_id])

    Amazon::FPS::AmazonLogger::log_multi_token_response(params, session)
    AmazonFlexPay.verify_request request

    session[:contribution_id] = nil
    @contribution.payment_key = params[:tokenID]
    @contribution.confirmed = true
    if !@contribution.save
      return redirect_to @contribution.project, alert: ERROR_STRING
    else
      EmailManager.contribute_to_project(@contribution).deliver if user_signed_in?

      log_user_action :save
      return redirect_to @contribution.project, alert: "Contribution submitted. Thank you for your support!"
    end
  rescue
    redirect_to @contribution.project, alert: ERROR_STRING
  end

  def edit
    initialize_old_contribution

    @contribution = Contribution.new
  end

  def update
    initialize_old_contribution
    @contribution = Contribution.new params[:contribution]

    #Setup contribution parameters that aren't specified by user...
    @contribution = Contribution.new params[:contribution]
    @contribution.payment_key = Contribution::UNDEFINED_PAYMENT_KEY #To pass validation at valid?
    @contribution.user_id = current_user.id if user_signed_in?
    @contribution.project = @project

    if @project.end_date < Date.today
      return redirect_to @project, error: "You cannot edit your contribution because this project is no longer taking contributions."
    end

    if !@contribution.valid?
      return render action: :edit
    end

    if @contribution.amount <= @old_contribution.amount
      @contribution.errors.add(:amount, "must be more than the original amount")
      return render action: :edit
    end
    @contribution.save

    session[:contribution_id] = @contribution.id
    session[:old_contribution_id] = @old_contribution.id

    log_user_action :update

    redirect_to AmazonFlexPay.multi_use_pipeline(
      UUIDTools::UUID.random_create.to_s,
      update_save_contribution_url,
      recipient_token_list: @project.payment_account_id,
      global_amount_limit: @contribution.amount
    )
  end

  def update_save
    if session[:contribution_id].nil? or session[:old_contribution_id].nil?
      return redirect_to root_path, alert: ERROR_STRING
    end
    @contribution = Contribution.find session[:contribution_id]
    @old_contribution = Contribution.find(session[:old_contribution_id])

    Amazon::FPS::AmazonLogger::log_multi_token_response(params, session)
    unless AmazonFlexPay.verify_request(request)
      redirect_to @contribution.project, alert: ERROR_STRING
    end

    session[:contribution] = nil
    session[:old_contribution_id] = nil

    @contribution.payment_key = params[:tokenID]

    if !@contribution.save
      return redirect_to @contribution.project, alert: ERROR_STRING
    end

    if !@old_contribution.cancel
      @contribution.cancel
      return redirect_to @contribution.project, alert: ERROR_STRING
    else # success
      EmailManager.edit_contribution(@old_contribution, @contribution).deliver

      log_user_action :update_save
      return redirect_to @contribution.project, alert: "Contribution successfully updated. Thank you for your support!"
    end
  rescue
    redirect_to @contribution.project, alert: ERROR_STRING
  end

  protected
  # TODO move to CanCan
  def validate_project(project)
    if !project.state.active?
      redirect_to root_path, alert: ERROR_STRING
    end
  end

  def initialize_old_contribution
    @old_contribution = Contribution.find(params[:id])

    @project = @old_contribution.project
    authorize! :edit, @old_contribution
    validate_project @project

  rescue ActiveRecord::RecordNotFound
    redirect_to root_url, alert: ERROR_STRING
  end

  # TODO get rid of this
  def prepare_contribution
    contribution = Contribution.new params[:contribution]

    #Setup contribution parameters that aren't specified by user...
    #TODO this can be a default value in the database
    contribution.payment_key = Contribution::UNDEFINED_PAYMENT_KEY #To pass validation at valid?
    contribution.user_id = current_user.id if user_signed_in?
    return contribution
  end

  def log_user_action event
    UserAction.create(user: current_user,
                      subject: @contribution,
                      event: event,
                      message: "amount: #{@contribution.amount}")
  end
end
