# === Attributes
#
# * *name* (+string+)
# * *short_description* (+string+)
# * *long_description* (+text+)
# * *funding_goal* (+integer+)
# * *end_date* (+date+)
# * *category_id* (+integer+)
# * *active* (+boolean+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *picture_file_name* (+string+)
# * *picture_content_type* (+string+)
# * *picture_file_size* (+integer+)
# * *picture_updated_at* (+datetime+)
# * *user_id* (+integer+)
# * *payment_account_id* (+string+)
# * *confirmed* (+boolean+)
# * *state* (+string+)
class Project < ActiveRecord::Base
  MAX_NAME_LENGTH = 75
  MAX_SHORT_DESC_LENGTH = 200
  MAX_LONG_DESC_LENGTH = 50000
  UNDEFINED_PAYMENT_ACCOUNT_ID = 'TEMP'

  include Rails.application.routes.url_helpers

  belongs_to :user
  has_many :contributions, conditions: ["status not in (:retry_cancel, :fail, :cancelled)", {retry_cancel: ContributionStatus::RetryCancel, fail: ContributionStatus::Failure, cancelled: ContributionStatus::Cancelled}]
  acts_as_commentable
  has_and_belongs_to_many :groups
  has_many :comments
  has_many :updates
  belongs_to :category
  has_one :video
  mount_uploader :picture, PictureUploader, mount_on: :picture_file_name
  has_many :approvals

  # Attributes --------------------------------------------------------------

  attr_accessible :name,
                  :short_description,
                  :long_description,
                  :funding_goal,
                  :end_date,
                  :category_id,
                  :picture,
                  :picture_cache

  classy_enum_attr :state, enum: 'ProjectState'

  # Validations --------------------------------------------------------------

  validate :end_date_in_future?, on: :create

  before_destroy :destroy_prep
  before_destroy :destroy_video

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: {maximum: MAX_NAME_LENGTH},
            format: { with: /\A[a-zA-Z0-9\s]+\z/,
            message: "can contatin only letters, numbers, and spaces." }

  validates :short_description,
            presence: true,
            length: {maximum: MAX_SHORT_DESC_LENGTH}

  validates :long_description,
            presence: true,
            length: {maximum: MAX_LONG_DESC_LENGTH}

  validates :funding_goal,
            numericality: { greater_than_or_equal_to: 5,
                            only_integer: true,
                            message: "must be at least $5, and a whole dollar amount (no cents please)"}

  validates :end_date,
            presence: { message: "must be of form 'MM/DD/YYYY'" }

  validates :payment_account_id, presence: true
  validates :category_id, presence: true
  validates :user, presence: true

  # Delegations --------------------------------------------------------------

  # Delegate these methods, so that we can call
  #     @project.can_edit?
  # instead of
  #     @project.state.can_edit?
  delegate :can_edit?, to: :state
  delegate :public_can_view?, to: :state
  delegate :can_update?, to: :state
  delegate :can_comment?, to: :state

  # Methods --------------------------------------------------------------

  # Sets end date from a string in the format "mm/dd/yyyy"
  def end_date=(val)
    write_attribute(:end_date, Timeliness.parse(val, format: "mm/dd/yyyy"))
  end

  # Sets the funding goal to a given amount
  def funding_goal=(val)
    write_attribute(:funding_goal, val.to_s.gsub(/,/, ''))
  end

  # Returns true if the end date exists and is in the future
  def end_date_in_future?
    if !end_date
      return
    elsif end_date < Date.today + 1
      errors.add(:end_date, "has to be in the future")
    end
  end

  # Returns the total amount of funding that has been received so far
  def contributions_total
    Rails.cache.fetch("#{self.id}_contributions_total") do 
      contributions.sum(:amount)
    end
  end

  # Returns a positive integer number representing the percentage of the funding goal that has been met
  def contributions_percentage
    Rails.cache.fetch("#{self.id}_contributions_percentage") do 
      ((contributions_total.to_f / funding_goal.to_f) * 100).to_i
    end
  end

  # Returns the amount of funding remaining until the project meets its funding goal
  def left_to_goal
    self.funding_goal - self.contributions_total
  end

  #Overriding to_param makes it so that whenever a url is built for a project, it substitues
  #the name of the project instead of the id of the project. This way, we can still refer
  #to params[:id] but it's actually the name. We didn't change the param to :name because
  #it was much more code that would be more error prone
  def to_param
    self.name.gsub(/\W/, '-')
  end

  # Sends email to project owner and all contributors, and destroys all contributions.
  # This method is executed before destroying each project.
  def destroy_prep
    EmailManager.project_deleted_to_owner(self).deliver  

    self.contributions.each do |contribution|
      EmailManager.project_deleted_to_contributor(contribution).deliver
      contribution.destroy
    end

    self.save
  end

  # Destroys video connected to the project.
  # This method is executed before destroying each project.
  def destroy_video
    unless video.nil?
      video.destroy
      self.save
    end
  end

  def update_project_video
    return if video.nil?

    default_url_options[:host] = "orithena.cas.msu.edu"
    tags = YT_TAGS
    description = "Contribute to this project: #{project_url(self)}\n\n#{video.description}\n\nFind more projects from MSU:\n#{root_url}\n"

    self.groups.each do |g|
      tags << g.name
      description += "\nFind more projects from #{g.name}:\n #{group_url(g)}"
    end

    Video.yt_session.video_update(video.yt_video_id, title: video.title, description: description, category: 'Tech', keywords: tags, list: "allowed")
  end

  def confirmation_approver?
    approvals.each do |approval|
      return true if approval.group.admin_user == current_user
    end
    return false
  end
end
