require 'amazon/fps/recipient_request'
require 'amazon/fps/amazon_logger'
require 'amazon/fps/amazon_validator'

class ProjectsController < InheritedResources::Base
  actions :all, :except => [ :create, :edit, :update, :destroy ]

  before_filter :authenticate_user!, :only => [ :new, :create, :edit, :update, :destroy, :save]
  #This allows us to use project names instead of ids for the routes
  before_filter :set_current_project_by_name, :only => [ :show, :edit, :update, :destroy ]
  #This is authorization through CanCan. The before_filter handles load_resource
  authorize_resource


  def index
    @projects = Project.where(:state => :active).order("end_date ASC").page(params[:page]).per(8)
    @lists = User.find_by_id(1) ? User.find(1).lists : []
    index!
  end

  def create
    @project = Project.new(params[:project])
    @project.user = current_user
    @project.payment_account_id = Project::UNDEFINED_PAYMENT_ACCOUNT_ID #To pass validation at valid?
    @project.state = :unconfirmed

    if @project.save
      unless params[:project][:video].nil?
        @project.video = Video.create(:title => @project.name, :description => "Contribute to this project: #{project_url(@project)}\n\n#{@project.short_description}\n\nFind more projects from MSU:#{root_url}", :project_id => @project.id)
        @project.video.delay.upload_video(params[:project][:video].path)
        @project.save # Save the ID of the video
      end

      session[:project_id] = @project.id

      request = Amazon::FPS::RecipientRequest.new(save_project_url)
      return redirect_to request.url
    else
      render :action => :new
    end
  end

  def update
    @project = Project.where(:name => params[:id].gsub(/-/, ' ')).first 

    if params[:project] && params[:project][:video]
      if @project.video
        Video.delete_video(@project.video)
      end

      @video = Video.create(title: @project.name, description: @project.short_description)
      @project.video = @video
      @video.project = @project
      @project.save!
      @video.save!

      @response = Video.yt_session.video_upload(params[:project][:video].tempfile, :title => @video.title, :description => "Contribute to this project: #{project_url(@project)}\n\n#{@video.description}\n\nFind more projects from MSU:#{root_url}", :category => 'Tech', :keywords => YT_TAGS, :list => "denied")

      if @response
        @video.update_attributes(:yt_video_id => @response.unique_id, :is_complete => true)
        @video.save!
        Video.delete_incomplete_videos
      else
        Video.delete_video(@video)
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
    @project = Project.find_by_name(params[:id].gsub(/-/, ' '))
    @video = @project.video

    @project.state = :active
    #make video public
    Video.yt_session.video_update(@video.yt_video_id, :title => @video.title, :description => "Contribute to this project: #{project_url(@project)}\n\n#{@video.description}\n\nFind more projects from MSU:#{root_url}", :category => 'Tech', :keywords => YT_TAGS, :list => "allowed") unless @video.nil?

    #send out emails for any group requests
    @project.approvals.each do |approval|
      @group = approval.group
      EmailManager.project_to_group_approval(approval, @project, @group).deliver
    end

    @project.save!
    flash[:notice] = "Successfully activated project."
    respond_with(@project)
  end

  def save
    Amazon::FPS::AmazonLogger::log_recipient_token_response(params)

    if !Amazon::FPS::AmazonValidator::valid_recipient_response?(save_project_url, session, params)
      flash[:alert] = "An error occurred with your project. Please try again."
      return redirect_to root_path
    end

    @project = Project.find(session[:project_id])
    @project.state = :inactive
    @project.payment_account_id = params[:tokenID]

    session[:project_id] = nil

    if !@project.save 
      flash[:alert] = "An error occurred with your project. Please try again."	
      return redirect_to root_path
    else
      #TODO: This is inconsistent. All the other project and contribution e-mails go through the 
      # model. Might be worth doing that for this too.
      successful_save

      flash[:alert] = "Project saved successfully. Here's to getting funded!"
      return redirect_to @project
    end
  end

  def destroy
    @project = Project.where(:name => params[:id].gsub(/-/, ' ')).first
    @video = @project.video

    if @project.state.unconfirmed? || @project.state.inactive?
      @project.destroy
      if !@project.destroyed?
        flash[:alert] = "Project could not be deleted. Please try again."
        return redirect_to @project
      else 
        flash[:alert] = "Project successfully deleted. Sorry to see you go!"
        return redirect_to root_path
      end
    elsif @project.state.active?
      #project will not be deleted but will be CANCELLED and only visible to user
      @project.state = :cancelled
      @project.save!
      @response = Video.yt_session.video_update(@video.yt_video_id, :title => @video.title, :description => "Contribute to this project: #{project_url(@project)}\n\n#{@video.description}\n\nFind more projects from MSU:#{root_url}", :category => 'People',:keywords => YT_TAGS, :list => "denied") if @video
      flash[:alert] = "Project successfully cancelled. This project is now only visible to you."
    else
      flash[:alert] = "You can not cancel or delete this project."
    end
    return redirect_to root_path
  end

  def show
    @project = Project.where(:name => params[:id].gsub(/-/, ' ')).first
    @project = ProjectDecorator.decorate @project if @project
    #somthing was up with this page and permissions so i moved them here
    return redirect_to root_path if @project.nil?
    return redirect_to root_path unless @project.public_can_view? or (logged_in? and (@project.confirmation_approver? or @project.user == current_user))

    @video = @project.video
    #for some reason youtube returns the most recent upload if the video token is nil
    if @video && @video.yt_video_id.nil?
      @video = nil
    end

    @rootComments = @project.root_comments
    @comment = Comment.new(params[:comment])
    @comment.commentable_id = @project.id
    @comment_depth = 0

    @update = Update.new(params[:update])
    @updates = @project.updates
  end

  def edit
    @project = Project.where(:name => params[:id].gsub(/-/, ' ')).first
    @video = @project.video
  end

  protected	
  def successful_save
    EmailManager.add_project(@project).deliver
  end
end
