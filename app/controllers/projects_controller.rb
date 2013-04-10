require 'amazon/fps/recipient_request'
require 'amazon/fps/amazon_logger'
require 'amazon/fps/amazon_validator'

class ProjectsController < InheritedResources::Base
  actions :all, except: [ :create, :edit, :update, :destroy ]

  before_filter :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :save]
  # Authorize the :new action through cancan, since we aren't explicitly defining the method
  # in this class.
  load_and_authorize_resource only: :new

  def index
    @projects = Project.where(state: :active).order("end_date ASC").page(params[:page]).per(8)
    authorize! :index, @projects
    @lists = User.find_by_id(1) ? User.find(1).lists : []
    index!
  end

  def create
    @project = Project.new(params[:project])
    @project.user = current_user
    @project.payment_account_id = Project::UNDEFINED_PAYMENT_ACCOUNT_ID #To pass validation at valid?
    @project.state = :unconfirmed
    @project.category = Category.find params[:project][:category_id] if params[:project][:category_id]
    authorize! :create, @project

    if @project.save
      unless params[:project][:video].nil?
        @project.video = Video.create(title: @project.name, project_id: @project.id)
        @project.video.delay.upload_video(params[:project][:video].path)
        @project.save # Save the ID of the video
      end

      session[:project_id] = @project.id

      request = Amazon::FPS::RecipientRequest.new(save_project_url)
      redirect_to request.url
    else
      render action: :new
    end
  end

  def update
    load_project_from_params
    authorize! :update, @project

    if params[:project] && params[:project][:video]
      if @project.video
        @project.video.destroy
        @project.video = nil
      end

      video = Video.create(title: @project.name, description: @project.short_description)
      @project.video = video
      video.project = @project
      @project.save!
      video.save!

      result = Video.yt_session.video_upload(params[:project][:video].tempfile,
                                             title: video.title,
                                             description: video.youtube_description,
                                             category: 'Tech',
                                             keywords: video.tags,
                                             list: "denied")

      if result
        video.update_attributes(yt_video_id: result.unique_id, is_complete: true)
        video.save!
        Video.delete_incomplete_videos
      else
        @project.video.destroy
        @project.video = nil
      end
    end

    if @project.update_attributes(params[:project])
      flash[:notice] = "Successfully updated project."
    end

    if @project.state.unconfirmed?
      session[:project_id] = @project.id
      request = Amazon::FPS::RecipientRequest.new(save_project_url)
      return redirect_to request.url
    else
      respond_with(@project)
    end
  end

  def activate
    load_project_from_params
    authorize! :activate, @project
    video = @project.video

    @project.state = :active

    #make video public
    video.public = true unless video.nil?

    #send out emails for any group requests
    @project.approvals.each do |approval|
      group = approval.group
      EmailManager.project_to_group_approval(approval, @project, group).deliver
    end

    @project.save!
    flash[:notice] = "Successfully activated project."
    respond_with(@project)
  end

  def block
    load_project_from_params
    authorize! :block, @project
    video = @project.video

    @project.state = :blocked

    #make video non-public
    video.public = false unless video.nil?

    #TODO send out email to project owner
    #TODO send out emails to any contributors

    @project.save!
    flash[:notice] = "Successfully blocked project."
    redirect_to @project
  end

  def unblock
    load_project_from_params
    authorize! :unblock, @project

    # TODO reset project state to unconfirmed or inactive
    if @project.payment_account_id == Project::UNDEFINED_PAYMENT_ACCOUNT_ID
      @project.state = :unconfirmed
    else
      @project.state = :inactive
    end

    #TODO send out email to project owner

    @project.save!
    flash[:notice] = "Successfully unblocked project."
    redirect_to @project
  end

  def save
    Amazon::FPS::AmazonLogger::log_recipient_token_response(params)
    project = Project.find(session[:project_id])
    authorize! :save, project

    if !Amazon::FPS::AmazonValidator::valid_recipient_response?(save_project_url, session, params)
      return redirect_to root_path, alert: 'An error occured with your project. Please try again.'
    end

    project.state = :inactive
    project.payment_account_id = params[:tokenID]

    session[:project_id] = nil

    if project.save
      #TODO: This is inconsistent. All the other project and contribution e-mails go through the
      # model. Might be worth doing that for this too.
      successful_save project

      flash[:notice] = "Project saved successfully. Here's to getting funded!"
      redirect_to project
    else
      flash[:alert] = "An error occurred with your project. Please try again."
      redirect_to root_path
    end
  end

  def destroy
    load_project_from_params
    authorize! :destroy, @project
    video = @project.video

    # TODO this should change to use CanCan
    if @project.state.unconfirmed? || @project.state.inactive?
      @project.destroy
      if !@project.destroyed?
        flash[:alert] = "Project could not be deleted. Please try again."
        return redirect_to @project
      else
        flash[:notice] = "Project successfully deleted. Sorry to see you go!"
        return redirect_to root_path
      end
    elsif @project.state.active?
      #project will not be deleted but will be CANCELLED and only visible to user
      @project.state = :cancelled
      @project.save!
      video.published = false
      flash[:notice] = "Project successfully cancelled. This project is now only visible to you."
    else
      flash[:alert] = "You can not cancel or delete this project."
    end
    redirect_to root_path
  end

  def show
    load_project_from_params
    authorize! :show, @project
    @project = ProjectDecorator.decorate @project

    # Existing comments
    @rootComments = @project.root_comments
    @comment_depth = 0
    # For new comments
    @comment = @project.comments.new params[:comment]

    # Existing updates
    @updates = @project.updates
    # For new updates
    @update = @project.updates.new params[:update]
  end

  def edit
    load_project_from_params
    authorize! :edit, @project
  end

  protected
  # TODO rename this method -- and all of the email methods while we're at it
  def successful_save(project)
    EmailManager.add_project(project).deliver
  end

  def load_project_from_params
    @project = Project.find_by_name! params[:id].gsub(/-/, ' ')
  end
end
