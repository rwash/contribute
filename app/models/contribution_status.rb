class ContributionStatus < ActiveRecord::Base
	has_many :contributions

	def self.None
		ContributionStatus.find_by_name('None')
	end

	def self.Success
		ContributionStatus.find_by_name('Success')
	end

	def self.Pending
		ContributionStatus.find_by_name('Pending')
	end

	def self.Failed
		ContributionStatus.find_by_name('Failed')
	end

	def self.Cancelled
		ContributionStatus.find_by_name('Cancelled')
	end

	def self.Retry_Pay
		ContributionStatus.find_by_name('Retry_Pay')
	end

	def self.Retry_Cancel
		ContributionStatus.find_by_name('Retry_Cancel')
	end
end
