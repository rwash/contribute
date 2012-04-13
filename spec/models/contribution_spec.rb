require "spec_helper"

describe Contribution do

#Begin Properties
	describe "valid case" do
		contribution = FactoryGirl.create(:contribution)

		it "saves properly" do
			assert contribution.save, "Should have saved valid contribution"
		end

		it "retry count is 0" do
			assert_equal contribution.retry_count, 0, "Retry count should be equal to zero" 
		end

		it "status is none" do
			assert_equal contribution.status, ContributionStatus::NONE, "Status should be none"
		end
	end

	describe "payment key" do
		it "is required" do
			contribution = FactoryGirl.build(:contribution, :payment_key => "")
			assert !contribution.save, "Incorrectly saved contribution without payment key"
		end
	end
		
	describe "amount" do
		it "is required" do
			contribution = FactoryGirl.build(:contribution, :amount => "")
			assert !contribution.save, "Incorrectly saved contribution without an amount"
		end
		it "is above 1" do
			contribution = FactoryGirl.build(:contribution, :amount => 0)
			assert !contribution.save, "Incorrectly saved contribution without amount below minimum contribution"
		end
		it "takes amounts with commas" do
			contribution = FactoryGirl.build(:contribution, :amount => '9,999,999')
			assert contribution.save, "Should have saved contribution with amount with commas"
		end
		it "is an integer" do
			contribution = FactoryGirl.build(:contribution, :amount => 5.5)
			assert !contribution.save, "Incorrectly saved contribution with amount that's not an int"
		end
	end

	describe "project" do
		it "is required" do
			contribution = FactoryGirl.build(:contribution, :project_id => "")
			assert !contribution.save, "Incorrectly saved contribution without a project"
		end
	end

	describe "user" do
		it "is required" do
			contribution = FactoryGirl.build(:contribution, :user_id => "")
			assert !contribution.save, "Incorrectly saved contribution without a user"
		end
	end
#End Properties

#Begin Methods
	describe "cancel" do

	end

	describe "execute_payment" do

	end

	describe "update_status" do

	end

	describe "destroy" do
		
	end
#End Methods
end
