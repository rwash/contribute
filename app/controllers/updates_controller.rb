class UpdatesController < InheritedResources::Base
  def create
    @update = Update.new(params[:update])
    @project = params[:project]
    
    if user_signed_in? && (@project.user.id == current_user.id)
      @update.user_id = current_user.id
      if @update.valid? && @update.save
        flash[:notice] = "Update saved succesfully."
        redirect_to @project
      else
        flash[:error] = "Update failed to save."
        redirect_to @project
      end
    else
      flash[:notice] = "You must be logged in to post an update."
      redirect_to @project
    end
  end
  
  
end
