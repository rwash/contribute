class UpdatesController < InheritedResources::Base
  before_filter :authenticate_user!

  # TODO get rid of @ for local variables
  def create
    @update = Update.new(params[:update])
    @project = Project.find(params[:project_id])
    authorize! :create_update_for, @project, message: "You cannot update projects you don't own."
    @update.project = @project
    @update.email_sent = false

    @update.user = current_user
    flash[:notice] = @update.save ? "Update saved succesfully." : "Update failed to save. Please try again."
    redirect_to @project
  end

end
