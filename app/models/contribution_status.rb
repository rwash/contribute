class ContributionStatus < ActiveRecord::Base
	has_many :contributions

	def self.None
		1
	end

	def self.Success
		2
	end

	def self.Pending
		3
	end

	def self.Failed
		4
	end

	def self.Cancelled
		5
	end

	def self.Retry_Pay
		6
	end

	def self.Retry_Cancel
		7
	end
end
