# This is the ruby that is behind the retry_contributions rake task
# Pulling it out makes it way easier to test
require 'logger'

class RetryContributions
  @@logger = Logger.new('log/cron_log.log')
  @@still_failing = Array.new

  def self.run
    @@logger.info "#{Date.today}: Starting contributions_retry"

    check_pending
    retry_pay
    retry_cancel

    if @@still_failing.any?
      EmailManager.failed_retries(@@still_failing).deliver
    end

    @@logger.info "#{Date.today}: All contributions have been processed\n"
  end

  def self.check_pending
    to_check_pending = Contribution.find_all_by_status(:pending)
    @@logger.info "Found #{to_check_pending.size} contributions to check pending"

    to_check_pending.each do |contribution|
      @@logger.info "Contribution with id #{contribution.id} is checking status"
      contribution.update_status
      # This value might need to be tweaked depending on how many e-mails it causes
      if contribution.retry_count > 3
        @@still_failing.push contribution
      end
    end
  end

  def self.retry_pay
    to_retry_pay = Contribution.find_all_by_status(:retry_pay)
    @@logger.info "Found #{to_retry_pay.size} contributions to retry pay"

    to_retry_pay.each do |contribution|
      @@logger.info "Contribution with id #{contribution.id} is retrying payment"
      contribution.execute_payment
      # This value might need to be tweaked depending on how many e-mails it causes
      if contribution.retry_count > 3
        @@still_failing.push contribution
      end
    end
  end

  def self.retry_cancel
    to_retry_cancel = Contribution.find_all_by_status(:retry_cancel)
    @@logger.info "Found #{to_retry_cancel.size} contributions to retry cancel"

    to_retry_cancel.each do |contribution|
      @@logger.info "Contribution with id #{contribution.id} is retrying cancellation"
      contribution.cancel
      # This value might need to be tweaked depending on how many e-mails it causes
      if contribution.retry_count > 3
        @@still_failing.push contribution
      end
    end
  end
end
