require "spec_helper"
require 'amazon/fps/pay_request'
require 'amazon/fps/get_transaction_status_request'
require 'amazon/fps/cancel_token_request'
require 'amazon/fps/amazon_validator'

describe Contribution do
  #Begin Properties
  describe "valid case" do
    let(:contribution) { Factory :contribution }

    it "saves properly" do
      expect(contribution.save).to be_true
    end

    it "retry count is 0" do
      expect(contribution.retry_count).to eq(0)
    end

    it "status is none" do
      expect(contribution.status).to eq(:none)
    end
  end

  describe "payment key" do
    it "is required" do
      contribution = FactoryGirl.build(:contribution, payment_key: "")
      expect(contribution.save).to be_false
    end
  end

  describe "amount" do
    it "is required" do
      contribution = FactoryGirl.build(:contribution, amount: "")
      expect(contribution.save).to be_false
    end
    it "fails below minimum" do
      contribution = FactoryGirl.build(:contribution, amount: (Contribution::MIN_CONTRIBUTION_AMT - 1))
      expect(contribution.save).to be_false
    end
    it "takes amounts with commas" do
      contribution = FactoryGirl.build(:contribution, amount: '9,999,999')
      expect(contribution.save).to be_true
    end
    it "is an integer" do
      contribution = FactoryGirl.build(:contribution, amount: 5.5)
      expect(contribution.save).to be_false
    end
  end

  describe "project" do
    it "is required" do
      contribution = FactoryGirl.build(:contribution, project_id: "")
      expect(contribution.save).to be_false
    end
  end

  describe "user" do
    it "is required" do
      contribution = FactoryGirl.build(:contribution, user_id: "")
      expect(contribution.save).to be_false
    end
  end
  #End Properties

  #Begin Methods
  describe "cancel" do
    before(:each) do
      Amazon::FPS::CancelTokenRequest.any_instance.stub(:send) {}
    end

    it 'on success, updates contribution status, sets retry count to 0, and e-mails user' do
      Amazon::FPS::AmazonValidator.stub(:get_cancel_status) { :success }
      EmailManager.stub_chain(:contribution_cancelled, deliver: true)
      contribution = FactoryGirl.create(:contribution)

      EmailManager.should_receive(:contribution_cancelled).with(contribution).once

      contribution.cancel

      expect(contribution.status).to eq :cancelled
      expect(contribution.retry_count).to eq 0
    end

    it 'on retriable error, updates contribution status and increments retry count' do
      Amazon::FPS::AmazonValidator.stub(:get_cancel_status) { :failure }
      Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('retriable') }

      contribution = FactoryGirl.create(:contribution, retry_count: 2)
      contribution.cancel

      expect(contribution.status).to eq :retry_cancel
      expect(contribution.retry_count).to eq 3
    end

    it 'on unretriable error that should e-mail user, updates contribution status, emails admin' do
      Amazon::FPS::AmazonValidator.stub(:get_cancel_status) { :failure }
      Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_user') }
      EmailManager.stub_chain(:unretriable_cancel_to_admin, deliver: true)
      contribution = FactoryGirl.create(:contribution)

      EmailManager.should_receive(:unretriable_cancel_to_admin).with(instance_of(AmazonError), contribution).once

      contribution.cancel

      expect(contribution.status).to eq :failure
    end

    it 'on unretriable error that should e-mail admin, updates contribution status and emails admin' do
      Amazon::FPS::AmazonValidator.stub(:get_cancel_status) { :failure }
      Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_admin') }
      EmailManager.stub_chain(:unretriable_cancel_to_admin, deliver: true)
      contribution = FactoryGirl.create(:contribution)

      EmailManager.should_receive(:unretriable_cancel_to_admin).with(instance_of(AmazonError), contribution).once

      contribution.cancel

      expect(contribution.status).to eq :failure
    end

    it 'on unretriable error that should e-mail user and admin, updates contribution status, emails admin' do
      Amazon::FPS::AmazonValidator.stub(:get_cancel_status) { :failure }
      Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_both') }
      EmailManager.stub_chain(:unretriable_cancel_to_admin, deliver: true)
      contribution = FactoryGirl.create(:contribution)

      EmailManager.should_receive(:unretriable_cancel_to_admin).with(instance_of(AmazonError), contribution).once

      contribution.cancel

      expect(contribution.status).to eq :failure
    end

  end

  describe "execute_payment" do
    before(:each) do
      Amazon::FPS::PayRequest.any_instance.stub(send: { 'PayResult' => { 'TransactionId' => 'abcdefg'} })
    end

    it 'on success, updates contribution status, sets retry count to 0, sets transaction id, and sends e-mail to user' do
      Amazon::FPS::AmazonValidator.stub(:get_pay_status) { :success }
      EmailManager.stub_chain(:contribution_successful, deliver: true)
      contribution = FactoryGirl.create(:contribution)
      contribution.project = mock_model(Project)

      EmailManager.should_receive(:contribution_successful).with(contribution).once

      contribution.execute_payment

      expect(contribution.status).to eq :success
      expect(contribution.retry_count).to eq 0
      expect(contribution.transaction_id).to eq 'abcdefg'
    end

    it 'on pending, updates contribution status, sets retry count to 0, and sets transaction id' do
      Amazon::FPS::AmazonValidator.stub(:get_pay_status) { :pending }

      contribution = FactoryGirl.create(:contribution)
      contribution.project = mock_model(Project)
      contribution.execute_payment

      expect(contribution.status).to eq :pending
      expect(contribution.retry_count).to eq 0
      expect(contribution.transaction_id).to eq 'abcdefg'
    end

    it 'on cancelled, updates contribution status' do
      Amazon::FPS::AmazonValidator.stub(:get_pay_status) { :cancelled }
      EmailManager.stub_chain(:cancelled_payment_to_admin, deliver: true)
      contribution = FactoryGirl.create(:contribution)
      contribution.project = mock_model(Project)

      EmailManager.should_receive(:cancelled_payment_to_admin).with(contribution).once

      contribution.execute_payment

      expect(contribution.status).to eq :cancelled
    end

    it 'on retriable error, updates contribution status and increments retry count' do
      Amazon::FPS::AmazonValidator.stub(:get_pay_status) { :failure }
      Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('retriable') }

      contribution = FactoryGirl.create(:contribution, retry_count: 2)
      contribution.project = mock_model(Project)
      contribution.execute_payment

      expect(contribution.status).to eq :retry_pay
      expect(contribution.retry_count).to eq 3
    end

    it 'on unretriable error that should e-mail user, updates contribution status and e-mails user' do
      Amazon::FPS::AmazonValidator.stub(:get_pay_status) { :failure }
      Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_user') }
      EmailManager.stub_chain(:unretriable_payment_to_user, deliver: true)
      contribution = FactoryGirl.create(:contribution)
      contribution.project = mock_model(Project)

      EmailManager.should_receive(:unretriable_payment_to_user).with(instance_of(AmazonError), contribution).once

      contribution.execute_payment

      expect(contribution.status).to eq :failure
    end

    it 'on unretriable error that should e-mail admin, updates contribution status and emails admin' do
      Amazon::FPS::AmazonValidator.stub(:get_pay_status) { :failure }
      Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_admin') }
      EmailManager.stub_chain(:unretriable_payment_to_admin, deliver: true)
      contribution = FactoryGirl.create(:contribution)
      contribution.project = mock_model(Project)

      EmailManager.should_receive(:unretriable_payment_to_admin).with(instance_of(AmazonError), contribution).once

      contribution.execute_payment

      expect(contribution.status).to eq :failure
    end

    it 'on unretriable error that should e-mail user and admin, updates contribution status, emails both' do
      Amazon::FPS::AmazonValidator.stub(:get_pay_status) { :failure }
      Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_both') }
      EmailManager.stub_chain(:unretriable_payment_to_admin, deliver: true)
      EmailManager.stub_chain(:unretriable_payment_to_user, deliver: true)
      contribution = FactoryGirl.create(:contribution)
      contribution.project = mock_model(Project)

      EmailManager.should_receive(:unretriable_payment_to_admin).with(instance_of(AmazonError), contribution).once
      EmailManager.should_receive(:unretriable_payment_to_user).with(instance_of(AmazonError), contribution).once

      contribution.execute_payment

      expect(contribution.status).to eq :failure
    end

  end

  describe "update_status" do
    before(:each) do
      Amazon::FPS::GetTransactionStatusRequest.any_instance.stub(:send) {}
    end

    it 'on invalid response, e-mails admin error' do
      Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { false }
      Amazon::FPS::AmazonValidator.stub(:get_error) { FactoryGirl.create('email_both') }
      EmailManager.stub_chain(:failed_status_to_admin, deliver: true)
      contribution = FactoryGirl.create(:contribution, transaction_id: 'abcdefg')

      EmailManager.should_receive(:failed_status_to_admin).with(instance_of(AmazonError), contribution).once

      contribution.update_status
    end

    it 'on success, updates contribution status, sets retry count to 0, and sends e-mail to user' do
      Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { :success }
      Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }
      EmailManager.stub_chain(:contribution_successful, deliver: true)
      contribution = FactoryGirl.create(:contribution, transaction_id: 'abcdefg')

      EmailManager.should_receive(:contribution_successful).with(contribution).once

      contribution.update_status

      expect(contribution.status).to eq :success
      expect(contribution.retry_count).to eq 0
    end

    it 'on failure, updates contribution status and sends e-mail to user' do
      Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { :failure }
      Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }
      EmailManager.stub_chain(:failed_payment_to_user, deliver: true)
      contribution = FactoryGirl.create(:contribution, transaction_id: 'abcdefg')

      EmailManager.should_receive(:failed_payment_to_user).with(contribution).once

      contribution.update_status

      expect(contribution.status).to eq :failure
    end

    it 'on cancelled, updates contribution status and sends e-mail to admin' do
      Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { :cancelled }
      Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }
      EmailManager.stub_chain(:cancelled_payment_to_admin, deliver: true)
      contribution = FactoryGirl.create(:contribution, transaction_id: 'abcdefg')

      EmailManager.should_receive(:cancelled_payment_to_admin).with(contribution).once

      contribution.update_status

      expect(contribution.status).to eq :cancelled
    end

    it 'on pending, updates retry count' do
      Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { :pending }
      Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }

      contribution = FactoryGirl.create(:contribution, transaction_id: 'abcdefg', status: :pending, retry_count: 2)
      contribution.update_status

      expect(contribution.status).to eq :pending
      expect(contribution.retry_count).to eq 3
    end

  end

  describe "destroy" do
    it 'calls cancel' do
      Contribution.any_instance.stub(:cancel) {}

      contribution = FactoryGirl.create(:contribution, transaction_id: 'abcdefg')
      contribution.should_receive(:cancel).once

      contribution.destroy
    end	
  end
  #End Methods
end
