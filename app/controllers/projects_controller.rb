class ProjectsController < InheritedResources::Base
	actions :all, :except => [ :destroy ]

end
