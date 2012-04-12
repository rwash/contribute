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
		to_check_pending = Contribution.where("status = ?", ContributionStatus::PENDING)
		logger.info "Found #{to_check_pending.size} contributions to check pending"
	
		to_check_pending.each do |contribution|
			logger.info "Contribution with id #{contribution.id} is checking status"
			contribution.update_status
			# This value might need to be tweaked depending on how many e-mails it causes
			if contribution.retry_count > 3
				fail_array.push contribution
			end
		end
	end

	def retry_pay(fail_array, logger)
		to_retry_pay = Contribution.where("status = ?", ContributionStatus::RETRY_PAY)
		logger.info "Found #{to_retry_pay.size} contributions to retry pay"

		to_retry_pay.each do |contribution|
			logger.info "Contribution with id #{contribution.id} is retrying payment"
			contribution.execute_payment
			# This value might need to be tweaked depending on how many e-mails it causes
			if contribution.retry_count > 3
				fail_array.push contribution
			end
		end
	end

	def retry_cancel(fail_array, logger)
		to_retry_cancel = Contribution.where("status = ?", ContributionStatus::RETRY_CANCEL)
		logger.info "Found #{to_retry_cancel.size} contributions to retry cancel"

		to_retry_cancel.each do |contribution|
			logger.info "Contribution with id #{contribution.id} is retrying cancellation"
			contribution.cancel
			# This value might need to be tweaked depending on how many e-mails it causes
			if contribution.retry_count > 3
				fail_array.push contribution
			end
		end
	end

end
