require 'amazon/fps/multi_token_request'
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
    if !Amazon::FPS::AmazonValidator::valid_multi_token_response?(save_contribution_url, session, params)
      return redirect_to @contribution.project, alert: ERROR_STRING
    end

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
  end

  def edit
    initialize_editing_contribution

    @contribution = Contribution.new
  end

  def update
    initialize_editing_contribution
    @contribution = Contribution.new params[:contribution]

    #Setup contribution parameters that aren't specified by user...
    @contribution = prepare_contribution()
    # DONT CHANGE THIS LINE.
    # We don't want to do @contribution.project = @editing_contribution.project
    # because that will assign the entire project object. Later, we'll be storing this object in
    # the session variable. We're fine storing a single id, but we can't store the entire project.
    @contribution.project_id = @project.id

    if @project.end_date < Date.today
      return redirect_to @project, error: "You cannot edit your contribution because this project is no longer taking contributions."
    end

    if !@contribution.valid?
      return render action: :edit
    end

    if @contribution.amount <= @editing_contribution.amount
      @contribution.errors.add(:amount, "must be more than the original amount")
      return render action: :edit
    end

    session[:contribution] = @contribution
    session[:editing_contribution_id] = @editing_contribution.id
    request = Amazon::FPS::MultiTokenRequest.new(session, update_save_contribution_url, @project.payment_account_id, @contribution.amount, @project.name)

    log_user_action :update
    return redirect_to request.url
  end

  def update_save
    if session[:contribution].nil? or session[:editing_contribution_id].nil?
      return redirect_to root_path, alert: ERROR_STRING
    end
    @contribution = session[:contribution]

    Amazon::FPS::AmazonLogger::log_multi_token_response(params, session)
    if !Amazon::FPS::AmazonValidator::valid_multi_token_response?(update_save_contribution_url, session, params)
      return redirect_to @contribution.project, alert: ERROR_STRING
    end

    session[:contribution] = nil
    @editing_contribution = Contribution.find(session[:editing_contribution_id])
    session[:editing_contribution_id] = nil

    @contribution.payment_key = params[:tokenID]

    if !@contribution.save
      return redirect_to @contribution.project, alert: ERROR_STRING
    end

    if !@editing_contribution.cancel
      @contribution.cancel
      return redirect_to @contribution.project, alert: ERROR_STRING
    else # success
      EmailManager.edit_contribution(@editing_contribution, @contribution).deliver

      log_user_action :update_save
      return redirect_to @contribution.project, alert: "Contribution successfully updated. Thank you for your support!"
    end
  end

  protected
  # TODO move to CanCan
  def validate_project(project)
    if !project.state.active?
      redirect_to root_path, alert: ERROR_STRING
    end
  end

  def initialize_editing_contribution
    @editing_contribution = Contribution.find(params[:id])

    @project = @editing_contribution.project
    authorize! :edit, @editing_contribution
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
