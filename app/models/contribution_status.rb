class ContributionStatus < ActiveRecord::Base
	has_many :contributions

	#Amazon transaction statuses
	CANCELLED = "Cancelled"
	FAILURE = "Failure"
	PENDING = "Pending"
	SUCCESS = "Success"

	#Our own statuses
	NONE = 'None'
	RETRY_PAY = "Retry_Pay"
	RETRY_CANCEL = 'Retry_Cancel'

	def self.None
		ContributionStatus.find_by_name(NONE)
	end

	def self.Success
		ContributionStatus.find_by_name(SUCCESS)
	end

	def self.Pending
		ContributionStatus.find_by_name(PENDING)
	end

	def self.Failed
		ContributionStatus.find_by_name(FAILURE)
	end

	def self.Cancelled
		ContributionStatus.find_by_name(CANCELLED)
	end

	def self.Retry_Pay
		ContributionStatus.find_by_name(RETRY_PAY)
	end

	def self.Retry_Cancel
		ContributionStatus.find_by_name(RETRY_CANCEL)
	end
end
