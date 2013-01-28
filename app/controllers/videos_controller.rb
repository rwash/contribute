class VideosController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource

  def destroy
    @video = Video.find(params[:id])
    @project = @video.project

    if current_user.nil? || @project.user != current_user
      flash[:error] = "You can not delete the video for project you do not own."
      return redirect_to root_path
    end

    if Video.delete_video(@video)
      flash[:notice] = "Video Successfully Deleted"
    else
      flash[:error] = "Failed to Delete Video"
    end

    begin
      redirect_to :back
    rescue
      redirect_to @project
    end
  end

  protected
  def collection
    @videos ||= end_of_association_chain.completes
  end

end
