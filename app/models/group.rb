class Group < ActiveRecord::Base
	has_and_belongs_to_many :projects
	has_many :approvals
	has_many :lists, :as =>  :listable
	
	mount_uploader :picture, PictureUploader, :mount_on => :picture_file_name
	
	after_create :create_list
	after_save :approve_all
	
	def create_list
		self.lists << List.create(:listable_id => self.id, :listable_type => self.class.name)
	end
	
	def approve_all
		if self.open
			for approval in self.approvals.where(:approved => nil)
				@group = Group.find(approval.group_id)
				@project = Project.find(approval.project_id)
				
				approval.approved = true
				approval.save!
				
				@group.projects << @project unless @group.projects.include?(@project)
				@project.update_project_video unless @project.video_id.nil?
			end
		end
	end
end