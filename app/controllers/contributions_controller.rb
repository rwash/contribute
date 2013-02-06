require 'amazon/fps/multi_token_request'
require 'amazon/fps/amazon_logger'
require 'amazon/fps/amazon_validator'

ERROR_STRING = "An error occurred with your contribution. Please try again."

class ContributionsController < ApplicationController
  before_filter :authenticate_user!, only: [ :new, :create, :save, :edit, :update, :update_save, :destroy ]

  cache_sweeper :contribution_sweeper

  load_and_authorize_resource except: [:new, :create, :save, :show, :edit, :update_save]
  skip_authorization_check only: [:save, :show, :edit, :update_save]

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
        flash[:alert] = "An error occured while submitting your contribution. Please try again."
        return redirect_to @contribution.project
      end
      session[:contribution_id] = @contribution.id
      request = Amazon::FPS::MultiTokenRequest.new(session, save_contribution_url, @contribution.project.payment_account_id, @contribution.amount, @contribution.project.name)

      redirect_to request.url
    else
      flash[:alert] = "Sorry, this project is no longer taking contributions."
      render action: :new
    end
  end

  #Return URL from payment gateway
  def save
    if session[:contribution_id].nil?
      flash[:alert] = ERROR_STRING
      return redirect_to root_path
    end
    @contribution = Contribution.find(session[:contribution_id])

    Amazon::FPS::AmazonLogger::log_multi_token_response(params, session)
    if !Amazon::FPS::AmazonValidator::valid_multi_token_response?(save_contribution_url, session, params)
      flash[:alert] = ERROR_STRING
      return redirect_to @contribution.project
    end

    session[:contribution_id] = nil
    @contribution.payment_key = params[:tokenID]
    @contribution.confirmed = true
    if !@contribution.save
      flash[:alert] = ERROR_STRING
      return redirect_to @contribution.project
    else
      successful_save

      flash[:alert] = "Contribution submitted. Thank you for your support!"
      return redirect_to @contribution.project
    end
  end

  # Routing for edit and update doesn't work unless route for show exists
  # TODO look into the routing. This method shouldn't have to exist
  def show
    raise ActionController::RoutingError.new('Not Found')
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
    @contribution.project_id = @project.id

    if @project.end_date < Date.today
      flash[:error] = "You cannot edit your contribution because this project is no longer taking contributions."
      return redirect_to @project
    end

    if !@contribution.valid?
      return render action: :edit
    end

    if @contribution.amount < @editing_contribution.amount
      @contribution.errors.add(:amount, "can't be less than the original amount")
      return render action: :edit
    end

    if @contribution.amount == @editing_contribution.amount
      @contribution.errors.add(:amount, "No changes were made to your contribution")
      return render action: :edit
    end

    session[:contribution] = @contribution
    session[:editing_contribution_id] = @editing_contribution.id
    request = Amazon::FPS::MultiTokenRequest.new(session, update_save_contribution_url, @project.payment_account_id, @contribution.amount, @project.name)

    return redirect_to request.url
  end

  def update_save
    if session[:contribution].nil? or session[:editing_contribution_id].nil?
      flash[:alert] = ERROR_STRING
      return redirect_to root_path
    end
    @contribution = session[:contribution]

    Amazon::FPS::AmazonLogger::log_multi_token_response(params, session)
    if !Amazon::FPS::AmazonValidator::valid_multi_token_response?(update_save_contribution_url, session, params)
      flash[:alert] = ERROR_STRING
      return redirect_to @contribution.project
    end

    session[:contribution] = nil
    @editing_contribution = Contribution.find(session[:editing_contribution_id])
    session[:editing_contribution_id] = nil

    @contribution.payment_key = params[:tokenID]

    if !@contribution.save
      flash[:alert] = ERROR_STRING
      return redirect_to @contribution.project
    end

    if !@editing_contribution.cancel
      @contribution.cancel
      flash[:alert] = ERROR_STRING
      return redirect_to @contribution.project
    else
      successful_update

      flash[:alert] = "Contribution successfully updated. Thank you for your support!"
      return redirect_to @contribution.project
    end
  end

  protected
  # TODO move to CanCan
  def validate_project(project)
    if !project.state.active?
      flash[:alert] = ERROR_STRING
      redirect_to root_path
    end
  end

  def initialize_editing_contribution
    @editing_contribution = Contribution.find(params[:id])

    @project = @editing_contribution.project
    authorize! :edit_contribution, @project
    validate_project @project

  rescue ActiveRecord::RecordNotFound
    flash[:alert] = ERROR_STRING
    redirect_to root_url
  end

  # TODO get rid of this
  def prepare_contribution
    contribution = Contribution.new params[:contribution]

    #Setup contribution parameters that aren't specified by user...
    #TODO this can be a default value in the database
    contribution.payment_key = Contribution::UNDEFINED_PAYMENT_KEY #To pass validation at valid?
    if(user_signed_in?)
      contribution.user_id = current_user.id
    end
    return contribution
  end

  def successful_save
    if user_signed_in?
      EmailManager.contribute_to_project(@contribution).deliver
    end
  end

  def successful_update
    EmailManager.edit_contribution(@editing_contribution, @contribution).deliver
  end
end
