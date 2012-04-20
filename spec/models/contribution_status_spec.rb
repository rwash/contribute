require "spec_helper"

describe ContributionStatus do
	describe 'string_to_status' do
		it 'string is success, returns success' do
			param = "Success"

			status = ContributionStatus.string_to_status(param)

			assert_equal ContributionStatus::SUCCESS, status
		end

		it 'string is pending, returns pending' do
			param = "Pending"

			status = ContributionStatus.string_to_status(param)

			assert_equal ContributionStatus::PENDING, status
		end

		it 'string is cancelled, returns cancelled' do
			param = "Cancelled"

			status = ContributionStatus.string_to_status(param)

			assert_equal ContributionStatus::CANCELLED, status
		end

		it 'string is failure, returns failure' do
			param = "Failure"

			status = ContributionStatus.string_to_status(param)

			assert_equal ContributionStatus::FAILURE, status
		end

		it 'string is nomatch, returns nil' do
			param = "NoMatch"

			status = ContributionStatus.string_to_status(param)
			
			assert_nil status
		end
	end

	describe 'status_to_string' do
		it 'status is none, returns none' do
			param = ContributionStatus::NONE

			string = ContributionStatus.status_to_string(param)

			assert_equal "None", string
		end

		it 'status is success, returns success' do
			param = ContributionStatus::SUCCESS

			string = ContributionStatus.status_to_string(param)

			assert_equal "Success", string
		end

		it 'status is pending, returns pending' do
			param = ContributionStatus::PENDING

			string = ContributionStatus.status_to_string(param)

			assert_equal "Pending", string
		end
		
		it 'status is failure, returns failure' do
			param = ContributionStatus::FAILURE

			string = ContributionStatus.status_to_string(param)

			assert_equal "Failure", string
		end

		it 'status is cancelled, returns cancelled' do
			param = ContributionStatus::CANCELLED

			string = ContributionStatus.status_to_string(param)

			assert_equal "Cancelled", string
		end

		it 'status is retry pay, returns retry - payment' do
			param = ContributionStatus::RETRY_PAY

			string = ContributionStatus.status_to_string(param)

			assert_equal "Retry - Payment", string
		end

		it 'status is retry cancel, returns retry - cancellation' do
			param = ContributionStatus::RETRY_CANCEL

			string = ContributionStatus.status_to_string(param)

			assert_equal "Retry - Cancellation", string
		end

		it 'status is invalid status, returns nil' do
			param = 8

			string = ContributionStatus.status_to_string(param)

			assert_nil string
		end
	end
end
