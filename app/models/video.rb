class Video < ActiveRecord::Base
  
  scope :completes,   where(:is_complete => true)
  scope :incompletes, where(:is_complete => false)
    
  def self.yt_session
    @yt_session ||= YouTubeIt::Client.new(:username => YT_USERNAME , :password => YT_PASSWORD , :dev_key => YT_DEV_KEY)    
  end

  def self.delete_video(video)
    yt_session.video_delete(video.yt_video_id)
    video.destroy
      rescue
        video.destroy
  end

  def self.update_video(video, params)
    yt_session.video_update(video.yt_video_id, video_options(params[:title], params[:description]))
    video.update_attributes(params)
  end

  def self.token_form(title, description, nexturl)
    yt_session.upload_token(video_options(title, description), nexturl)
  end

  def self.delete_incomplete_videos
    self.incompletes.map{|r| r.destroy}
  end

  private
    def self.video_options(title, description)
      opts = {:title => title,
             :description => description,
             :category => "People",
             :keywords => ["test"]}
      #params[:is_unpublished] == "1" ? opts.merge(:private => "true") : opts
    end
end