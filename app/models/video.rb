# === Attributes
#
# * *title* (+string+)
# * *description* (+string+)
# * *yt_video_id* (+string+)
# * *is_complete* (+boolean+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *project_id* (+integer+)
class Video < ActiveRecord::Base
  belongs_to :project

  scope :completes,   where(:is_complete => true)
  scope :incompletes, where(:is_complete => false)

  validates_presence_of :project

  include Rails.application.routes.url_helpers

  def upload_video(path)
    puts "Uploading video at #{path}"
    tempfile = File.open path
    response = Video.yt_session.video_upload(tempfile, :title => self.title, :description => self.description, :category => 'Tech',:keywords => YT_TAGS, :list => "denied")

    unless response.nil?
      self.update_attributes(:yt_video_id => response.unique_id, :is_complete => true)
      self.save!
    end
  end
  handle_asynchronously :upload_video

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
