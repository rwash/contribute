class UpdatesController < InheritedResources::Base
  def create
    @update = Update.new(params[:update])
    @project = Project.where(:id => params[:project_id]).first
<<<<<<< HEAD
    @update.project_id = @project.id
=======
>>>>>>> 8e07dbcd19c35d7adbe4e46c7905cff8a84e62e7
    
    if user_signed_in? && (@project.user_id == current_user.id)
      @update.user_id = current_user.id
      if @update.valid? && @update.save
        flash[:notice] = "Update saved succesfully."
        redirect_to @project
      else
        flash[:error] = "Update failed to save."
        redirect_to @project
      end
    else
      flash[:notice] = "You must be logged in and be the project owner to post an update."
      redirect_to @project
    end
  end
  
end
