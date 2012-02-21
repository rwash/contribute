#https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview

class User < ActiveRecord::Base
	require 'file_size_validator'
	mount_uploader :picture, PictureUploader, :mount_on => :picture_file_name

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable,
				 :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :location, :picture, :picture_cache

	has_many :projects, :dependent => :destroy

	validates :name, :presence => true

	validates :picture, :file_size => {:maximum => 0.15.megabytes.to_i }

	def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
		data = access_token.extra.raw_info
		if user = User.where(:email => data.email).first
			user
		else # Create a user with a stub password. 
			User.create!(:email => data.email, :name => data.name, :location => data.location.name, :password => Devise.friendly_token[0,20], :confirmed_sent_at => Time.now, :confirmed_at => Time.now) 
		end
	end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]
				user.name = data["name"]
				user.location.name = data["location"]["name"]
      end
    end
	end
end
