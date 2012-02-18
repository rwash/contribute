class ProjectsController < InheritedResources::Base
	actions :all, :except => [ :destroy ]

	before_filter :authenticate_user!, :only => [ :new, :create, :edit, :update ]
	#This allows us to use project names instead of ids for the routes
	before_filter :set_current_project_by_name, :only => [ :show, :edit, :update ]
	#This is authorization through CanCan. The before_filter handles load_resource
	authorize_resource

	def index
		@projects = Project.limit(9).where("active = 1").order("end_date ASC")
		@projects1 = @projects.slice(0..2)
		@projects2 = @projects.slice(3..5)
		@projects3 = @projects.slice(6..8)
		index!
	end

	def create
		@project = Project.new(params[:project])
		@project.user_id = current_user.id
		create!
	end
end
