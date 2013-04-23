class GroupsController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :save, :new_add, :submit_add]

  def index
    @groups = Group.all

    @user_groups = current_user.nil? ? [] : current_user.projects.map { |p| p.groups }.flatten.uniq
    @admin_groups = current_user.nil? ? [] : current_user.owned_groups
  end

  def create
    @group = Group.new(params[:group])
    @group.admin_user = current_user

    if @group.save!
      redirect_to @group, notice: "Successfully created group."
    else
      redirect_to new_group_path, error: "Failed to save group. Please try again."
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
    group = Group.find(params[:id])
    project = Project.find(params[:project_id])

    if project.nil?
      #Do Nothing
    elsif project.state.cancelled?
      flash[:error] = "You cannot add a cancelled project."
    elsif group.projects.include?(project)
      flash[:error] = "Your project is already in this group."
    elsif group.open?
      group.projects << project
      video = project.video
      project.update_project_video unless video.nil?

      flash[:notice] = "Your project has been added to the group."
    elsif project.approvals.where(group_id: group.id, status: :pending).any?
      flash[:error] = "You have already submitted this project. Please wait for the admin to approve or reject your request."
    elsif group.admin_user == current_user
      group.projects << project
      flash[:notice] = "Your project has been added."
    else
      approval = Approval.create(group: group, project: project)
      flash[:notice] = "Your project has been submitted to the group admin for approval."
      EmailManager.project_to_group_approval(approval, project, group).deliver
    end

    redirect_to group
  end

  def admin
    @group = Group.find(params[:id])
    @approval = Approval.find_by_id(params[:approval_id])
  end

  def remove_project
    group = Group.find(params[:id])
    project = Project.find(params[:project_id].gsub(/-/, ' '))
    if group.admin_user == current_user or project.user == current_user
      group.projects.delete(project)
      project.update_project_video
      flash[:notice] = "#{project.name} removed from group #{group.name}."
    else
      flash[:error] = "You do not have permission to remove this project."
    end

    begin
      redirect_to :back
    rescue
      redirect_to :group
    end
  end

  def destroy
    group = Group.find(params[:id])
    flash[:error] = "Failed to delete group. Please try again." unless group.destroy
    redirect_to groups_path
  end
end
