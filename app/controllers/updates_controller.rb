class UpdatesController < InheritedResources::Base
  def create
    @update = Update.new(params[:update])
    @project = Project.find(params[:project_id])
    @update.project_id = @project.id
    @update.email_sent = false
    
    if user_signed_in? && (@project.user_id == current_user.id)
      @update.user_id = current_user.id
      if @update.valid? && @update.save
        flash[:notice] = "Update saved succesfully."
      else
        flash[:error] = "Update failed to save."
      end
    else
      flash[:error] = "You must be logged in and be the project owner to post an update."
    end
    redirect_to @project
  end
  
end
