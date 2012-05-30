require 'tasks/update_contributors'

namespace :contribute do
	task :completed_projects => :environment do
		UpdateContributors.run
	end
end