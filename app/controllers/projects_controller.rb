class ProjectsController < InheritedResources::Base
	authorize_resource
	
	actions :all, :except => [ :destroy ]
	#This allows us to use project names instead of ids for the routes
	before_filter :set_current_project_by_name, :only => [ :show, :edit, :update ]

	def index
		@projects = Project.limit(8).where("active = 1").order("end_date ASC")
		index!
	end

	def create
		@project = Project.new(params[:project])
		@project.user_id = current_user.id
		create!
	end
end
