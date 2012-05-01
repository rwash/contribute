require 'tasks/completed_projects'

namespace :contribute do
	# This task is scheduled to run and processes all projects that have an end date of yesterday
	task :completed_projects => :environment do
		CompletedProjects.run
	end

	# This task is run when needed and processes all projects with an end date of yesterday or before
	task :all_completed_projects => :environment do
		CompletedProjects.run_all
	end
end

