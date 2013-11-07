class GroupsController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :save]

  def index
    @groups = Group.all

    @user_groups = current_user.nil? ? [] : current_user.projects.map { |p| p.groups }.flatten.uniq
    @admin_groups = current_user.nil? ? [] : current_user.owned_groups
  end

  def create
    @group = Group.new(params[:group])
    @group.owner = current_user

    if @group.save
      log_user_action :create, @group.name
      redirect_to @group, notice: "Successfully created group."
    else
      render action: :new
    end
  end

  def remove_project
    @group = Group.find(params[:id])
    project = Project.find(params[:project_id].gsub(/-/, ' '))
    if current_user_can_edit_project? project
      @group.projects.delete(project)
      project.update_project_video
      log_user_action :remove_project, params
      flash[:notice] = "#{project.name} removed from group #{@group.name}."
    else
      flash[:error] = "You do not have permission to remove this project."
    end

    begin
      redirect_to :back
    rescue
      redirect_to @group
    end
  end

  def destroy
    @group = Group.find(params[:id])
    if @group.destroy
      log_user_action :destroy
    else
      flash[:error] = "Failed to delete group. Please try again."
    end
    redirect_to groups_path
  end

  private
  def log_user_action event, message=nil
    UserAction.create user: current_user, subject: @group, event: event, message: message
  end

  def current_user_can_edit_project? project
    [@group.owner, project.owner].include? current_user
  end
end
