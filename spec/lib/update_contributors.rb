require "spec_helper"
require "tasks/update_contributors"

describe UpdateContributors do
	describe "integration tests" do
		before(:all) do

		end

		after(:each) do

		end

		it "run works" do

			project = FactoryGirl.build(:project, :state => 'active', :end_date => 1.week.from_now )
			project.save(:validate => false)
			
			update = FactoryGirl.build(:update, :email_sent => false, :project_id => project.id, :user_id => 1)
			update.save(:validate => false)

			Contribution.any_instance.stub(:execute_payment) {}
			Contribution.any_instance.stub(:cancel) {}

			to_funded = FactoryGirl.create(:contribution, :amount => 15, :project_id => project.id)
			to_funded2 = FactoryGirl.create(:contribution2, :amount => 100, :project_id => project.id)
			
			EmailManager.stub_chain(:project_update_to_contributor, :deliver => true)
			update.email_sent = true
			
			EmailManager.should_receive(:project_update_to_contributor).with(update, to_funded).once
			EmailManager.should_receive(:project_update_to_contributor).with(update, to_funded2).once
			
			UpdateContributors.run
		end
	end
end
