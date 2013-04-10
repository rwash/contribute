# === Attributes
#
# * *yt_video_id* (+string+)
# * *is_complete* (+boolean+)
# * *published* (+boolean+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *project_id* (+integer+)
class Video < ActiveRecord::Base
  belongs_to :project

  scope :completes,   where(is_complete: true)
  scope :incompletes, where(is_complete: false)

  validates_presence_of :project

  extend ActiveModel::Callbacks
  define_model_callbacks :destroy

  before_destroy :delete_yt_video

  include Rails.application.routes.url_helpers

  def upload_video(path)
    puts "Uploading video at #{path}"
    tempfile = File.open path
    response = Video.yt_session.video_upload(tempfile, options_hash)

    unless response.nil?
      self.update_attributes(yt_video_id: response.unique_id, is_complete: true)
      self.save!
    end
  end
  handle_asynchronously :upload_video

  def update
    Video.yt_session.video_update(yt_video_id, options_hash)
  end

  def self.yt_session
    @yt_session ||= YouTubeIt::Client.new(username: YT_USERNAME , password: YT_PASSWORD , dev_key: YT_DEV_KEY)
  end

  def delete_yt_video
    yt_session.video_delete(yt_video_id)
  rescue
  end

  def self.token_form(title, description, nexturl)
    yt_session.upload_token(video_options, nexturl)
  end

  def self.delete_incomplete_videos
    self.incompletes.map{|r| r.destroy}
  end

  protected

  def options_hash
    {
      title: project.name,
      description: youtube_description,
      category: 'Tech',
      keywords: tags,
      list: list
    }
  end

  def youtube_description
    yt_desc = ["Contribute to this project: #{project_url(project)}",
     "#{project.short_description}",
     "Find more projects from MSU: #{root_url}"].join('\n\n')

    project.groups.each do |g|
      yt_desc += "\nFind more projects from #{g.name}:\n #{group_url(g)}"
    end

    yt_desc
  end

  def tags
    YT_TAGS + project.groups.map(&:name)
  end

  def list
    published ? 'allowed' : 'denied'
  end

end
