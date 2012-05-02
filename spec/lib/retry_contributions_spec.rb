require "spec_helper"
require "tasks/retry_contributions"

describe RetryContributions do
	describe "integration run tests" do
# TODO: Can't get should_receives to work on objects, as opposed to static classes
# Tried stubbing on the object itself and should receiving on Contribution. No luck.
#		it "success tests" do
#			Contribution.delete_all
#			Project.delete_all
#			User.delete_all
#
#			user = FactoryGirl.create(:user)
#			project = FactoryGirl.create(:project)
#
#			Contribution.any_instance.stub(:update_status) {}
#			Contribution.any_instance.stub(:execute_payment) {}
#			Contribution.any_instance.stub(:cancel) {}
#
#			success = FactoryGirl.create(:contribution, :status => ContributionStatus::SUCCESS, :retry_count => 0)
#			pending = FactoryGirl.create(:contribution2, :status => ContributionStatus::PENDING, :retry_count => 0)
#			retry_cancel = FactoryGirl.create(:contribution3, :status => ContributionStatus::RETRY_CANCEL, :retry_count => 0)
#			retry_pay = FactoryGirl.create(:contribution4, :status => ContributionStatus::RETRY_PAY, :retry_count => 0)
#				
#			pending.should_receive(:update_status).once
#			retry_cancel.should_receive(:cancel).once
#			retry_pay.should_receive(:execute_payment).once
#
#			RetryContributions.run
#		end

		it "failure tests" do
			Contribution.delete_all
			Project.delete_all
			User.delete_all

			user = FactoryGirl.create(:user)
			project = FactoryGirl.create(:project)

			Contribution.any_instance.stub(:update_status) {}
			Contribution.any_instance.stub(:execute_payment) {}
			Contribution.any_instance.stub(:cancel) {}

			success = FactoryGirl.create(:contribution, :status => ContributionStatus::SUCCESS, :retry_count => 4)
			pending = FactoryGirl.create(:contribution2, :status => ContributionStatus::PENDING, :retry_count => 4)
			retry_cancel = FactoryGirl.create(:contribution3, :status => ContributionStatus::RETRY_CANCEL, :retry_count => 4)
			retry_pay = FactoryGirl.create(:contribution4, :status => ContributionStatus::RETRY_PAY, :retry_count => 4)
			
			EmailManager.stub_chain(:failed_retries, :deliver => true)
			expectedArray = [ pending, retry_pay, retry_cancel ]
			EmailManager.should_receive(:failed_retries).with(expectedArray)
	
			RetryContributions.run
		end
	end
end
