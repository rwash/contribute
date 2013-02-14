class VideosController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource

  def destroy
    video = Video.find(params[:id])
    project = video.project

    if Video.delete_video(video)
      flash[:notice] = "Video Successfully Deleted"
    else
      flash[:error] = "Failed to Delete Video"
    end

    begin
      redirect_to :back
    rescue
      redirect_to project
    end
  end

  protected
  def collection
    @videos ||= end_of_association_chain.completes
  end

end
