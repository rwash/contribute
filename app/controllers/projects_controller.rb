class ProjectsController < InheritedResources::Base
	actions :all, :except => [ :destroy ]
	#This allows us to use project names instead of ids for the routes
	before_filter :set_current_project_by_name, :only => [ :show, :edit, :update ]

	def index
		@projects = Project.limit(8).where("active = 1").order("end_date ASC")
		index!
	end
end
