class UpdatesController < InheritedResources::Base
  before_filter :authenticate_user!

  def create
    project = Project.find(params[:project_id])
    update = project.updates.new(params[:update])
    authorize! :create, update, message: "You cannot update this project."
    update.project = project
    update.email_sent = false

    update.user = current_user
    if update.save
      flash[:notice] = "Update saved successfully."
      UserAction.create user: current_user, event: :create, subject: update
    else
      flash[:alert] = "Update failed to save. Please try again."
    end
    redirect_to project
  end

end
