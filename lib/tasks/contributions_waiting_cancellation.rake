#TODO: This needs to log somewhere

namespace :contribute do
	task :contributions_waiting_cancellation => :environment do
		contributions_to_process = Contribution.where("waiting_cancellation > 0")

		contributions_to_process.each do |contribution|
			contribution.cancel
			if contribution.waiting_cancellation > 3
				#TODO: send an e-mail to the admin to check on this
			end
		end
	end
end
