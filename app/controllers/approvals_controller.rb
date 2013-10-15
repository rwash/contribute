class ApprovalsController < InheritedResources::Base	
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

    redirect_to group_admin_path(group)
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

    redirect_to group_admin_path(group)
  end

  private
  def log_user_action event
    UserAction.create user: current_user, subject: approval, event: event
  end

  def approval
    @_approval ||= Approval.find(params[:id])
  end

  def group
    @_group ||= Group.find(params[:group_id])
  end
end
