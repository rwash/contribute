require 'tasks/update_contributors'

namespace :contribute do
	task :update_contributors => :environment do
		UpdateContributors.run
	end
end