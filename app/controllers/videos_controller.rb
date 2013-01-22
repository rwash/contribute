class VideosController < InheritedResources::Base
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
    redirect_to :back
  end

  protected
  def collection
    @videos ||= end_of_association_chain.completes
  end

end
