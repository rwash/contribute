class ProjectsController < InheritedResources::Base
	actions :all, :except => [ :destroy ]

	def index
		@projects = Project.limit(10).where("active = 1").order("endDate ASC")
		index!
	end
end
