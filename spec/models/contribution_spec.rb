require "spec_helper"
require 'amazon/fps/pay_request'
require 'amazon/fps/get_transaction_status_request'
require 'amazon/fps/cancel_token_request'
require 'amazon/fps/amazon_validator'   

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
		it "fails below minimum" do
			contribution = FactoryGirl.build(:contribution, :amount => (Contribution::MIN_CONTRIBUTION_AMT - 1))
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
		before(:each) do
			Amazon::FPS::CancelTokenRequest.any_instance.stub(:send) {}
		end

		it 'on success, updates contribution status, sets retry count to 0, and e-mails user' do
			Amazon::FPS::AmazonValidator.stub(:get_cancel_status) { ContributionStatus::SUCCESS }
			EmailManager.stub_chain(:contribution_cancelled, :deliver => true)
			EmailManager.should_receive(:contribution_cancelled).once

			contribution = FactoryGirl.create(:contribution)
			contribution.cancel

			assert_equal ContributionStatus::CANCELLED, contribution.status
			assert_equal 0, contribution.retry_count
		end
		
		it 'on retriable error, updates contribution status and increments retry count' do
			Amazon::FPS::AmazonValidator.stub(:get_cancel_status) { ContributionStatus::FAILURE }
			Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('retriable') }

			contribution = FactoryGirl.create(:contribution, :retry_count => 2)
			contribution.cancel

			assert_equal ContributionStatus::RETRY_CANCEL, contribution.status
			assert_equal 3, contribution.retry_count
		end

		it 'on unretriable error that should e-mail user, updates contribution status, emails admin' do
			Amazon::FPS::AmazonValidator.stub(:get_cancel_status) { ContributionStatus::FAILURE }
			Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_user') }
			EmailManager.stub_chain(:unretriable_cancel_to_admin, :deliver => true)
			EmailManager.should_receive(:unretriable_cancel_to_admin).once   

			contribution = FactoryGirl.create(:contribution)
			contribution.cancel

			assert_equal ContributionStatus::FAILURE, contribution.status
		end

		it 'on unretriable error that should e-mail admin, updates contribution status and emails admin' do
			Amazon::FPS::AmazonValidator.stub(:get_cancel_status) { ContributionStatus::FAILURE }
			Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_admin') }
			EmailManager.stub_chain(:unretriable_cancel_to_admin, :deliver => true)
			EmailManager.should_receive(:unretriable_cancel_to_admin).once

			contribution = FactoryGirl.create(:contribution)
			contribution.cancel

			assert_equal ContributionStatus::FAILURE, contribution.status
		end

		it 'on unretriable error that should e-mail user and admin, updates contribution status, emails admin' do
			Amazon::FPS::AmazonValidator.stub(:get_cancel_status) { ContributionStatus::FAILURE }
			Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_both') }
			EmailManager.stub_chain(:unretriable_cancel_to_admin, :deliver => true)
			EmailManager.should_receive(:unretriable_cancel_to_admin).once   

			contribution = FactoryGirl.create(:contribution)
			contribution.cancel

			assert_equal ContributionStatus::FAILURE, contribution.status
		end

	end

	describe "execute_payment" do
		before(:each) do
			Amazon::FPS::PayRequest.any_instance.stub(:send => { 'PayResult' => { 'TransactionId' => 'abcdefg'} }) 
		end

		it 'on success, updates contribution status, sets retry count to 0, sets transaction id, and sends e-mail to user' do
			Amazon::FPS::AmazonValidator.stub(:get_pay_status) { ContributionStatus::SUCCESS }
			EmailManager.stub_chain(:contribution_successful, :deliver => true)
			EmailManager.should_receive(:contribution_successful).once

			contribution = FactoryGirl.create(:contribution)
			contribution.project = mock_model(Project)
			contribution.execute_payment

			assert_equal ContributionStatus::SUCCESS, contribution.status
			assert_equal 0, contribution.retry_count
			assert_equal 'abcdefg', contribution.transaction_id
		end

		it 'on pending, updates contribution status, sets retry count to 0, and sets transaction id' do
			Amazon::FPS::AmazonValidator.stub(:get_pay_status) { ContributionStatus::PENDING }

			contribution = FactoryGirl.create(:contribution)
			contribution.project = mock_model(Project)
			contribution.execute_payment

			assert_equal ContributionStatus::PENDING, contribution.status
			assert_equal 0, contribution.retry_count
			assert_equal 'abcdefg', contribution.transaction_id
		end
	
		it 'on cancelled, updates contribution status' do
			Amazon::FPS::AmazonValidator.stub(:get_pay_status) { ContributionStatus::CANCELLED }
			EmailManager.stub_chain(:cancelled_payment_to_admin, :deliver => true)
			EmailManager.should_receive(:cancelled_payment_to_admin).once

			contribution = FactoryGirl.create(:contribution)
			contribution.project = mock_model(Project)
			contribution.execute_payment

			assert_equal ContributionStatus::CANCELLED, contribution.status
		end

		it 'on retriable error, updates contribution status and increments retry count' do
			Amazon::FPS::AmazonValidator.stub(:get_pay_status) { ContributionStatus::FAILURE }
			Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('retriable') }

			contribution = FactoryGirl.create(:contribution, :retry_count => 2)
			contribution.project = mock_model(Project)
			contribution.execute_payment

			assert_equal ContributionStatus::RETRY_PAY, contribution.status
			assert_equal 3, contribution.retry_count
		end

		it 'on unretriable error that should e-mail user, updates contribution status and e-mails user' do
			Amazon::FPS::AmazonValidator.stub(:get_pay_status) { ContributionStatus::FAILURE }
			Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_user') }
			EmailManager.stub_chain(:unretriable_payment_to_user, :deliver => true)
			EmailManager.should_receive(:unretriable_payment_to_user).once

			contribution = FactoryGirl.create(:contribution)
			contribution.project = mock_model(Project)
			contribution.execute_payment

			assert_equal ContributionStatus::FAILURE, contribution.status
		end

		it 'on unretriable error that should e-mail admin, updates contribution status and emails admin' do
			Amazon::FPS::AmazonValidator.stub(:get_pay_status) { ContributionStatus::FAILURE }
			Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_admin') }
			EmailManager.stub_chain(:unretriable_payment_to_admin, :deliver => true)
			EmailManager.should_receive(:unretriable_payment_to_admin).once

			contribution = FactoryGirl.create(:contribution)
			contribution.project = mock_model(Project)
			contribution.execute_payment

			assert_equal ContributionStatus::FAILURE, contribution.status
		end

		it 'on unretriable error that should e-mail user and admin, updates contribution status, emails both' do
			Amazon::FPS::AmazonValidator.stub(:get_pay_status) { ContributionStatus::FAILURE }
			Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_both') }
			EmailManager.stub_chain(:unretriable_payment_to_admin, :deliver => true)
			EmailManager.stub_chain(:unretriable_payment_to_user, :deliver => true)
			EmailManager.should_receive(:unretriable_payment_to_admin).once
			EmailManager.should_receive(:unretriable_payment_to_user).once

			contribution = FactoryGirl.create(:contribution)
			contribution.project = mock_model(Project)
			contribution.execute_payment

			assert_equal ContributionStatus::FAILURE, contribution.status
		end

	end

	describe "update_status" do
		before(:each) do
			Amazon::FPS::GetTransactionStatusRequest.any_instance.stub(:send) {}
		end

		it 'on invalid response, e-mails admin error' do
			Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { false }
			Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_both') }
			EmailManager.stub_chain(:failed_status_to_admin, :deliver => true)
			EmailManager.should_receive(:failed_status_to_admin).once

			contribution = FactoryGirl.create(:contribution, :transaction_id => 'abcdefg')
			contribution.update_status
		end

		it 'on success, updates contribution status, sets retry count to 0, and sends e-mail to user' do
			Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { ContributionStatus::SUCCESS }
			Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }
			EmailManager.stub_chain(:contribution_successful, :deliver => true)
			EmailManager.should_receive(:contribution_successful).once

			contribution = FactoryGirl.create(:contribution, :transaction_id => 'abcdefg')
			contribution.update_status

			assert_equal ContributionStatus::SUCCESS, contribution.status
			assert_equal 0, contribution.retry_count
		end

		it 'on failure, updates contribution status and sends e-mail to user' do
			Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { ContributionStatus::FAILURE }
			Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }
			EmailManager.stub_chain(:failed_payment_to_user, :deliver => true)
			EmailManager.should_receive(:failed_payment_to_user).once

			contribution = FactoryGirl.create(:contribution, :transaction_id => 'abcdefg')
			contribution.update_status

			assert_equal ContributionStatus::FAILURE, contribution.status
		end

		it 'on cancelled, updates contribution status and sends e-mail to admin' do
			Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { ContributionStatus::CANCELLED }
			Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }
			EmailManager.stub_chain(:cancelled_payment_to_admin, :deliver => true)
			EmailManager.should_receive(:cancelled_payment_to_admin).once

			contribution = FactoryGirl.create(:contribution, :transaction_id => 'abcdefg')
			contribution.update_status

			assert_equal ContributionStatus::CANCELLED, contribution.status
		end

		it 'on pending, updates retry count' do
			Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { ContributionStatus::PENDING }
			Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }

			contribution = FactoryGirl.create(:contribution, :transaction_id => 'abcdefg', :status => ContributionStatus::PENDING, :retry_count => 2)
			contribution.update_status

			assert_equal ContributionStatus::PENDING, contribution.status
			assert_equal 3, contribution.retry_count
		end

	end

	describe "destroy" do
		it 'calls cancel' do
			Contribution.any_instance.stub(:cancel) {}
			
			contribution = FactoryGirl.create(:contribution, :transaction_id => 'abcdefg')
			contribution.should_receive(:cancel).once

			contribution.destroy
		end	
	end
#End Methods
end
