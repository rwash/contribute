class VideosController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource

  def destroy
    video = Video.find(params[:id])
    project = video.project

    if video.destroy
      flash[:notice] = t('videos.destroy.success.flash')
    else
      flash[:error] = t('videos.destroy.failure.flash')
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
