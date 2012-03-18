class User < ActiveRecord::Base
	require 'file_size_validator'
	mount_uploader :picture, PictureUploader, :mount_on => :picture_file_name

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :location, :picture, :picture_cache

	has_many :projects, :dependent => :destroy
	has_many :contributions, :conditions => {:cancelled => 0, :waiting_cancellation => 0}

	validates :name, :presence => true

	validates :picture, :file_size => {:maximum => 0.15.megabytes.to_i }
end
