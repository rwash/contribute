class UpdatesController < InheritedResources::Base
  def create
    @update = Update.new(params[:update])
    @project = Project.where(:id => params[:project_id]).first
    
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
