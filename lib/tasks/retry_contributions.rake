require 'tasks/retry_contributions'

namespace :contribute do
	task :retry_contributions => :environment do
		RetryContributions.run
	end
end
