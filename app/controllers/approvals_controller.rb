class ApprovalsController < InheritedResources::Base	

  load_and_authorize_resource except: :index
  before_filter :authenticate_user!, only: [:index, :new, :create]

  def index
    @group = Group.find(params[:group_id])
    # TODO change this ability name to :read, @approvals
    authorize! :admin, @group
    @approvals = @group.approvals
    @approval = Approval.find_by_id(params[:approval_id])
  end

  def new
    @group = Group.find(params[:group_id])
    @projects = []
    for proj in current_user.projects
      @projects << proj if !@group.projects.include?(proj) && proj.state != 'cancelled'
    end
  end

  def create
    group = Group.find(params[:group_id])
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
      @approval = Approval.create(group: group, project: project, status: :approved)
      log_user_action :create, params
    elsif project.approvals.where(group_id: group.id, status: :pending).any?
      flash[:error] = "You have already submitted this project. Please wait for the admin to approve or reject your request."
    elsif group.owner == current_user
      group.projects << project
      flash[:notice] = "Your project has been added."
      log_user_action :create, params
    else
      @approval = Approval.create(group: group, project: project)
      flash[:notice] = "Your project has been submitted to the group admin for approval."
      EmailManager.project_to_group_approval(approval, project, group).deliver
      log_user_action :create, params
    end

    redirect_to group
  end

  def approve
    authorize! :approve, approval

    if approval.status.pending?
      approval.status = :approved
      approval.save!
      log_user_action :approve

      project = approval.project
      group.projects << project unless group.projects.include?(project)
      project.update_project_video
    else
      # TODO move approval state to an enumeration
      flash[:error] = "This project has already been #{approval.status}."
    end

    redirect_to group_approvals_path(group)
  end

  def reject
    project = Project.find(approval.project_id)

    authorize! :reject, approval

    if approval.status.pending?
      approval.reason = params[:reason]
      approval.status = :rejected
      approval.save!
      log_user_action :reject

      EmailManager.group_reject_project(approval, project, group).deliver
    else
      flash[:error] = "This project has already been #{approval.status}."
    end

    redirect_to group_approvals_path(group)
  end

  private
  def log_user_action event, message=nil
    UserAction.create user: current_user, subject: approval, event: event, message: message.to_json
  end

  def approval
    @approval ||= Approval.find(params[:id])
  end

  def group
    @_group ||= Group.find(params[:group_id])
  end
end
