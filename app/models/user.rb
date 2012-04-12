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
  has_many :contributions, :conditions => ["status not in (:retry_cancel, :fail, :cancelled)", {:retry_cancel => ContributionStatus::RETRY_CANCEL, :fail => ContributionStatus::FAILURE, :cancelled => ContributionStatus::CANCELLED}]

	validates :name, :presence => true
end
