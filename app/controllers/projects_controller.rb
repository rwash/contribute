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
    authorize! :index, Project
  end

  def create
    @project = Project.new(params[:project])
    @project.owner = current_user
    @project.state = :unconfirmed
    authorize! :create, @project

    if @project.save
      unless params[:project][:video].nil?
        @project.video = Video.create(title: @project.name, project_id: @project.id)
        @project.video.delay.upload_video(params[:project][:video].path)
        @project.save # Save the ID of the video
      end
      redirect_to project_path(@project)
    else
      render action: :new
    end
  end

  def update
    @project = project_from_params
    authorize! :update, @project

    if params[:project] && params[:project][:video]
      @project.video.destroy if @project.video

      @project.video = Video.create
      @project.video.delay.upload_video(params[:project][:video].path)

      if result
        @project.video.update_attributes(yt_video_id: result.unique_id, is_complete: true)
        Video.delete_incomplete_videos
      else
        @project.video.destroy
      end
    end

    if @project.update_attributes(params[:project])
      flash[:notice] = "Successfully updated project."
    end

    respond_with(@project)
  end

  def activate
    @project = project_from_params
    authorize! :activate, @project

    # TODO this will return true if save fails -- this is a very real possibility
    @project.activate!

    flash[:notice] = "Successfully activated project."
    respond_with(@project)
  end

  def block
    @project = project_from_params
    authorize! :block, @project

    @project.state = :blocked

    #make video non-published
    @project.video.published = false if @project.video

    #TODO send out email to project owner
    #TODO send out emails to any contributors

    @project.save!
    redirect_to @project, notice: "Successfully blocked project."
  end

  def unblock
    @project = project_from_params
    authorize! :unblock, @project

    # TODO reset project state to unconfirmed or inactive
    if @project.payment_account_id == Project::UNDEFINED_PAYMENT_ACCOUNT_ID
      @project.state = :unconfirmed
    else
      @project.state = :inactive
    end

    #TODO send out email to project owner

    @project.save!
    redirect_to @project, notice: "Successfully unblocked project."
  end

  def destroy
    @project = project_from_params
    authorize! :destroy, @project

    # TODO this should change to use CanCan
    if @project.state.unconfirmed? || @project.state.inactive?
      @project.destroy
      if !@project.destroyed?
        return redirect_to @project, alert: "Project could not be deleted. Please try again."
      else
        return redirect_to root_path, notice: "Project successfully deleted. Sorry to see you go!"
      end
    elsif @project.state.active?
      #project will not be deleted but will be CANCELLED and only visible to user
      @project.state = :cancelled
      @project.save!
      # TODO law of demeter violation
      @project.video.published = false
      @project.video.update
      flash[:notice] = "Project successfully cancelled. This project is now only visible to you."
      return redirect_to @project
    else
      flash[:alert] = "You can not cancel or delete this project."
    end
    redirect_to root_path
  end

  def show
    @project = project_from_params
    authorize! :show, @project
    @project = @project.decorate

    # Existing comments
    @rootComments = @project.root_comments
    # For new comments
    @comment = @project.comments.new params[:comment]

    # Existing updates
    @updates = @project.updates
    # For new updates
    @update = @project.updates.new params[:update]
  end

  def edit
    @project = project_from_params
    authorize! :edit, @project
  end

  protected
  def project_from_params
    Project.find_by_slug! params[:id]
  end
end
