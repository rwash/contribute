class Update < ActiveRecord::Base

	validates_presence_of :title
	validates_presence_of :content
	validates_presence_of :user_id
	validates_presence_of :project_id
	
	belongs_to :project
	belongs_to :user
  
end
