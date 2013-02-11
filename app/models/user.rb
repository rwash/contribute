# === Attributes
#
# * *email* (+string+)
# * *encrypted_password* (+string+)
# * *name* (+string+)
# * *location* (+string+)
# * *reset_password_token* (+string+)
# * *reset_password_sent_at* (+datetime+)
# * *remember_created_at* (+datetime+)
# * *sign_in_count* (+integer+)
# * *current_sign_in_at* (+datetime+)
# * *last_sign_in_at* (+datetime+)
# * *current_sign_in_ip* (+string+)
# * *last_sign_in_ip* (+string+)
# * *confirmation_token* (+string+)
# * *confirmed_at* (+datetime+)
# * *confirmation_sent_at* (+datetime+)
# * *unconfirmed_email* (+string+)
# * *failed_attempts* (+integer+)
# * *unlock_token* (+string+)
# * *locked_at* (+datetime+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *picture_file_name* (+string+)
# * *picture_content_type* (+string+)
# * *picture_file_size* (+integer+)
# * *picture_updated_at* (+datetime+)
# * *admin* (+boolean+)
# * *starred* (+boolean+)
# * *blocked* (+boolean+)
class User < ActiveRecord::Base
  mount_uploader :picture, PictureUploader, mount_on: :picture_file_name

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :location, :picture, :picture_cache, :blocked

  has_many :projects, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :contributions, conditions: ["status not in (:retry_cancel, :fail, :cancelled)", {retry_cancel: ContributionStatus::RetryCancel, fail: ContributionStatus::Failure, cancelled: ContributionStatus::Cancelled}]
  has_many :owned_groups, class_name: "Group", foreign_key: "admin_user_id"
  has_many :lists, as:  :listable

  validates :name, presence: true

  after_create :add_first_list

  # Override the default devise filter for active users
  # so that we can guard against blocked users
  def active_for_authentication?
    super && !blocked?
  end

  # If a user is not allowed to sign in, display the following error message
  # (found in config/locales/devise.##.yml)
  def inactive_message
    if blocked?
      :blocked
    else
      super
    end
  end

  def add_first_list
    self.lists << List.create(title: "#{self.name}'s Projects", permanent: true, show_funded: true, show_nonfunded: true, show_active: true)
  end
end
