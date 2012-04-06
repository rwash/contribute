require 'logger'

logger = Logger.new('log/cron_log.log')

namespace :contribute do
	task :retry_contributions => :environment do
		logger.info "#{Date.today}: Starting contributions_retry"

		still_failing = Array.new

		check_pending(still_failing, logger)
		retry_pay(still_failing, logger)
		retry_cancel(still_failing, logger)
	
		if still_failing.size > 0
			EmailManager.failed_retries(still_failing).deliver
		end
	
		logger.info "#{Date.today}: All contributions have been processed\n"
	end

	def check_pending(fail_array, logger)
		to_check_pending = Contribution.where("contribution_status_id = ?", ContributionStatus.Pending)
		logger.info "Found #{to_check_pending.size} contributions to check pending"
	
		to_check_pending.each do |contribution|
			logger.info "Contribution with id #{contribution.id} is checking status"
			#TODO: contribution.check_status
			if contribution.retry_count > 3
				fail_array.push contribution
			end
		end
	end

	def retry_pay(fail_array, logger)
		to_retry_pay = Contribution.where("contribution_status_id = ?", ContributionStatus.Retry_Pay)
		logger.info "Found #{to_retry_pay.size} contributions to retry pay"

		to_retry_pay.each do |contribution|
			logger.info "Contribution with id #{contribution.id} is retrying payment"
			contribution.execute_payment
			if contribution.retry_count > 3
				fail_array.push contribution
			end
		end
	end

	def retry_cancel(fail_array, logger)
		to_retry_cancel = Contribution.where("contribution_status_id = ?", ContributionStatus.Retry_Cancel)
		logger.info "Found #{to_retry_cancel.size} contributions to retry cancel"

		to_retry_cancel.each do |contribution|
			logger.info "Contribution with id #{contribution.id} is retrying cancellation"
			contribution.cancel
			if contribution.retry_count > 3
				fail_array.push contribution
			end
		end
	end

end
