class GroupsController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :authenticate_user!, :only => [ :new, :create, :edit, :update, :destroy, :save, :new_add]

  def index
    @groups = Group.all

    unless current_user.nil?
      @user_groups = current_user.projects.map { |p| p.groups }.flatten.uniq
      @admin_groups = current_user.owned_groups
    end
  end

  def create
    @group = Group.new(params[:group])
    @group.admin_user_id = current_user.id

    if @group.save!
      flash[:notice] = "Successfully created group."
      redirect_to @group
    else
      flash[:error] = "Failed to save group. Please try again."
      redirect_to new_group_path
    end
  end

  def new_add
    @group = Group.find(params[:id])
    @projects = []
    for proj in current_user.projects
      @projects << proj if !@group.projects.include?(proj) && proj.state != 'cancelled'
    end
  end

  def submit_add
    @group = Group.find(params[:id])
    @project = Project.find_by_id(params[:project_id])

    if @project.nil?
      #Do Nothing
    elsif @project.state.cancelled?
      flash[:error] = "You cannot add a cancelled project."
    elsif @group.projects.include?(@project)
      flash[:error] = "Your project is already in this group."
    elsif @group.open?
      @group.projects << @project			
      @video = Video.find_by_id(@project.video_id)
      @project.update_project_video unless @video.nil?

      flash[:notice] = "Your project has been added to the group."
    elsif !Approval.where(:group_id => @group.id, :project_id => @project.id, :approved => nil).first.nil?
      flash[:error] = "You have already submitted this project. Please wait for the admin to approve or reject your request."
    elsif @group.admin_user_id == current_user.id
      @group.projects << @project
      flash[:notice] = "Your project has been added."
    else
      @approval = Approval.create(:group_id => @group.id, :project_id => @project.id)
      flash[:notice] = "Your project has been submitted to the group admin for approval."
      EmailManager.project_to_group_approval(@approval, @project, @group).deliver
    end

    redirect_to @group
  end

  def admin
    @group = Group.find(params[:id])
    @approval = Approval.find_by_id(params[:approval_id])
    #@items = @group.lists.first.items
  end

  def remove_project
    @group = Group.find(params[:id])
    @project = Project.find_by_name(params[:project_id].gsub(/-/, ' '))
    if @group.admin_user_id == current_user.id or @project.user_id == current_user.id
      @group.projects.delete(@project)
      @project.update_project_video unless @project.video_id.nil?
      flash[:notice] = "#{@project.name} removed from group #{@group.name}."
    else
      flash[:error] = "You do not have permission to remove this project."
    end

    redirect_to :back
  end

  def add_list
    @group = Group.find(params[:id])
    @group.lists << List.create(:listable_id => @group.id, :listable_type => @group.class.name)

    redirect_to :back
  end

  def destroy
    @group = Group.find(params[:id])
    if !@group.destroy
      flash[:error] = "Failed to delete group. Please try again."
    end
    redirect_to groups_path
  end
end
