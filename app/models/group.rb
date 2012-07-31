class Group < ActiveRecord::Base
	has_and_belongs_to_many :projects
	has_many :approvals
	has_many :lists, :as =>  :listable
	
	mount_uploader :picture, PictureUploader, :mount_on => :picture_file_name
	
	after_create :create_list
	
	def create_list
		self.lists << List.create(:listable_id => self.id, :listable_type => self.class.name)
	end
end