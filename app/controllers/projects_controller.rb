class ProjectsController < InheritedResources::Base
	actions :all, :except => [ :destroy ]

	def index
		@projects = Project.limit(8).where("active = 1").order("end_date ASC")
		index!
	end
end
