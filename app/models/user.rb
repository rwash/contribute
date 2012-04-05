require 'file_size_validator'

class User < ActiveRecord::Base
	mount_uploader :picture, PictureUploader, :mount_on => :picture_file_name

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :location, :picture, :picture_cache

	has_many :projects, :dependent => :destroy
  has_many :contributions, :conditions => ["contribution_status_id not in (:retry_cancel, :fail, :cancelled)", {:retry_cancel => ContributionStatus.Retry_Cancel, :fail => ContributionStatus.Failed, :cancelled => ContributionStatus.Cancelled}]


	validates :name, :presence => true

	validates :picture, :file_size => {:maximum => 0.15.megabytes.to_i }
end
