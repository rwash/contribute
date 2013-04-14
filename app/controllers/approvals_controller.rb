class ApprovalsController < InheritedResources::Base	
  def approve
    approval = Approval.find(params[:id])
    group = Group.find(params[:group_id])

    authorize! :approve, approval

    if approval.status.pending?
      approval.status = :approved
      approval.save!

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
    approval = Approval.find(params[:id])
    group = Group.find(params[:group_id])
    project = Project.find(approval.project_id)

    authorize! :reject, approval

    if approval.status.pending?
      approval.reason = params[:reason]
      approval.status = :rejected
      approval.save!

      EmailManager.group_reject_project(approval, project, group).deliver
    else
      flash[:error] = "This project has already been #{approval.status}."
    end

    redirect_to group_admin_path(group)
  end
end
