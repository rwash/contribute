class UpdatesController < InheritedResources::Base
  def create
    @update = Update.new(params[:update])
    @project = Project.find(params[:project_id])
    @update.project = @project
    @update.email_sent = false

    if user_signed_in? && (@project.user == current_user)
      @update.user = current_user
      if @update.valid? && @update.save
        flash[:notice] = "Update saved succesfully."
      else
        flash[:error] = "Update failed to save. Please try again."
      end
    else
      flash[:error] = "You cannot update this project."
    end
    redirect_to @project
  end

end
