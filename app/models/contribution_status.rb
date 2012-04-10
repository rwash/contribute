class ContributionStatus < ActiveRecord::Base
	NONE = 1
	SUCCESS = 2
	PENDING = 3
	FAILURE = 4
	CANCELLED = 5
	RETRY_PAY = 6
	RETRY_CANCEL = 7

	# This doesn't include all of our statuses because these
	# are the only strings that come back from Amazon
	def self.string_to_status(string)
		case string
		when "Success"
			SUCCESS
		when "Pending"
			PENDING
		when "Cancelled"			
			CANCELLED
		when "Failure"
			FAILURE
		end
	end

	def self.status_to_string(status)
		case status
		when NONE
			"None"
		when SUCCESS
			"Success"
		when PENDING
			"Pending"
		when FAILURE
			"Failure"
		when CANCELLED
			"Cancelled"
		when RETRY_PAY
			"Retry - Payment"
		when RETRY_CANCEL
			"Retry - Cancellation"
		end
	end
end
