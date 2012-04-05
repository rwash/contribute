#TODO: This needs to log somewhere

namespace :contribute do
	task :contributions_waiting_cancellation => :environment do
		contributions_to_process = Contribution.where("waiting_cancellation > 0")
		contributions_still_failing = Array.new


		contributions_to_process.each do |contribution|
			contribution.cancel
			if contribution.retry_count > 3
				contributions_still_failing.push contribution	
			end
		end
	
		if contributions_still_failing.size > 0
			EmailManager.failed_cancellations(contributions_still_failing).deliver
		end
	end
end
