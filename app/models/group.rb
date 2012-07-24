class Group < ActiveRecord::Base
	has_and_belongs_to_many :projects
	has_many :approvals
	
	mount_uploader :picture, PictureUploader, :mount_on => :picture_file_name
	
end