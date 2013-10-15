# === Attributes
#
# * *name* (+string+)
# * *short_description* (+string+)
# * *long_description* (+text+)
# * *funding_goal* (+integer+)
# * *end_date* (+date+)
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
  # TODO change this to nil
  UNDEFINED_PAYMENT_ACCOUNT_ID = nil

  # TODO this shouldn't be here.
  include Rails.application.routes.url_helpers

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  has_many :contributions,
    conditions: ["status not in (:retry_cancel, :fail, :cancelled)",
                 {retry_cancel: ContributionStatus::RetryCancel,
                  fail: ContributionStatus::Failure,
                  cancelled: ContributionStatus::Cancelled}]
  acts_as_commentable
  has_and_belongs_to_many :groups
  has_many :comments, as: :commentable
  has_many :updates
  has_one :video
  has_one :amazon_payment_account
  mount_uploader :picture, PictureUploader, mount_on: :picture_file_name
  has_many :approvals

  # Attributes --------------------------------------------------------------

  attr_accessible :name,
                  :short_description,
                  :long_description,
                  :funding_goal,
                  :end_date,
                  :picture,
                  :picture_cache

  classy_enum_attr :state, enum: 'ProjectState'

  searchable do
    text :name, :short_description
    text :owner_name do
      owner.name rescue nil
    end
    boolean :active do
      state.active?
    end
  end

  # Validations --------------------------------------------------------------

  validate :end_date_in_future?, on: :create
  validate :has_payment_account_if_active?

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

  validates :owner, presence: true

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

  def payment_account_id
    amazon_payment_account.token
  rescue
    nil
  end

  def payment_account_id=(value)
    account = AmazonPaymentAccount.find_or_create_by_project_id id
    account.update_attributes token: value
  end

  # Sets end date from a string in the format "mm/dd/yyyy"
  def end_date=(val)
    write_attribute(:end_date, Timeliness.parse(val, format: "mm/dd/yyyy"))
  end

  # Sets the funding goal to a given amount
  def funding_goal=(val)
    write_attribute(:funding_goal, val.to_s.gsub(/,/, ''))
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

  def video
    super || NullVideo.new
  end

  # Destroys video connected to the project.
  # This method is executed before destroying each project.
  def destroy_video
    video.destroy
    self.save
  end

  def activate!
    self.state = :active

    # publish video
    self.video.published = true

    #send out emails for any group requests
    self.approvals.each do |approval|
      group = approval.group
      EmailManager.project_to_group_approval(approval, @project, group).deliver
    end

    self.save!
  end

  # TODO unneccesary
  def update_project_video
    return if video.nil?

    # TODO move this to config/environments/...
    default_url_options[:host] = "orithena.cas.msu.edu"

    video.update
  end

  # TODO badly formed method
  def confirmation_approver?
    approvals.each do |approval|
      return true if approval.group.owner == current_user
    end
    return false
  end

  protected

  # Validation
  # Returns true if the end date exists and is in the future
  def end_date_in_future?
    if !end_date
      return
    elsif end_date < Date.today + 1
      errors.add(:end_date, "has to be in the future")
    end
  end

  # Validation
  # Creates an error if project state is active and project has no payment_account_id
  def has_payment_account_if_active?
    errors.add(:state, "can't be active without a payment account id") if state.active? and payment_account_id.nil?
  rescue
  end

  def self.find_by_slug(slug)
    find_by_name slug.gsub(/-/, ' ')
  end

  def self.find_by_slug!(slug)
    find_by_name! slug.gsub(/-/, ' ')
  end
end
