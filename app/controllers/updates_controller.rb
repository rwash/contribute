class UpdatesController < InheritedResources::Base
  before_filter :authenticate_user!
  before_filter :set_project

  def new
    authorize! :create, @project.updates.new
    @update = @project.updates.new
  end

  def create
    update = @project.updates.new(params[:update])
    authorize! :create, update, message: "You cannot update this project."
    update.project = @project
    update.email_sent = false

    update.user = current_user
    if update.save
      flash[:notice] = "Update saved successfully."
      UserAction.create user: current_user, event: :create, subject: update
    else
      flash[:alert] = "Update failed to save. Please try again."
    end
    redirect_to @project
  end

  private
  def set_project
    @project = Project.find_by_slug! params[:project_id]
  end
end
