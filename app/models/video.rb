class Video < ActiveRecord::Base
  has_one :project
  
  scope :completes,   where(:is_complete => true)
  scope :incompletes, where(:is_complete => false)
  
  include Rails.application.routes.url_helpers
  
  def upload_video(project_id,path)
  	@project = Project.find_by_id(project_id)
  	@tempfile = File.open path
		@response = Video.yt_session.video_upload(@tempfile, :title => self.title, :description => self.description, :category => 'Tech',:keywords => YT_TAGS, :list => "denied")
		
	  if !@response.nil?
	  	self.update_attributes(:yt_video_id => @response.unique_id, :is_complete => true)
	    self.save!
	    Video.delete_incomplete_videos
	  else
	   Video.delete_video(@video)
	   @project.video_id = nil
	   @project.save!
	  end
  end
  #handle_asynchronously :upload_video
  
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
  	# may want to add a :dev_tab => "contribute", also may want to make the videos private ( but I like keeping them public.)
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