require "spec_helper"
require 'amazon/fps/pay_request'
require 'amazon/fps/transaction_status_request'
require 'amazon/fps/cancel_token_request'
require 'amazon/fps/amazon_validator'

describe Contribution do
  describe "default values" do
    let(:contribution) { create :contribution }

    it "sets retry count to 0" do
      expect(contribution.retry_count).to eq(0)
    end

    it "sets status to none" do
      expect(contribution.status).to eq(:none)
    end
  end

  describe 'validations' do
    it { should validate_presence_of :payment_key }

    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).only_integer.with_message(/whole dollar amount/) }
    it { should allow_value(1).for :amount }
    it { should_not allow_value(0).for :amount }
    it { should allow_value('9,999,999').for :amount }

    it { should validate_presence_of :project_id }
    it { should validate_presence_of :user_id }
  end

  # TODO overlap of tests between this and project model
  describe 'Abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:contribution) { build :contribution }
    let(:project) { contribution.project }

    context 'when not signed in' do
      let(:user) { nil }

      it { should_not be_able_to :create, contribution }
      it { should_not be_able_to :edit, contribution }
    end

    context 'when signed in' do
      let(:user) { create :user }

      it { should be_able_to :create, contribution }

      context 'one week after the end date' do
        before { Timecop.freeze project.end_date + 1.week }
        it { should_not be_able_to :create, contribution }
      end

      context 'one day after the end date' do
        before { Timecop.freeze project.end_date + 1 }
        it { should_not be_able_to :create, contribution }
      end

      context 'on end date' do
        before { Timecop.freeze project.end_date }
        it { should be_able_to :create, contribution }
      end

      context 'before end date' do
        before { Timecop.freeze project.end_date - 1 }
        it { should be_able_to :create, contribution }
      end
    end

    context 'when user owns project' do
      let(:user) { contribution.project.owner }

      it { should_not be_able_to :create, contribution }
      it { should_not be_able_to :edit, contribution }
    end

    context 'when user owns contribution' do
      let(:user) { create :user }
      let(:contribution) { create :contribution, user: user }

      it { should be_able_to :update, contribution }
      it { should be_able_to :edit, contribution }
    end

    context 'when signed in as admin' do
      let(:user) { create :user, admin: true }

      it { should be_able_to :create, contribution }
      it { should_not be_able_to :update, contribution }
      it { should be_able_to :update, create(:contribution, user: user) }
    end
  end

  describe "#cancel" do
    let(:contribution) { create :contribution }

    before do
      EmailManager.stub_chain(:contribution_cancelled, deliver: true)
    end

    context 'on success' do
      before { AmazonFlexPay.stub(:cancel_token) }

      it 'emails user' do
        EmailManager.should_receive(:contribution_cancelled).with(contribution).once
        contribution.cancel
      end

      it 'updates contribution status' do
        contribution.cancel
        expect(contribution.reload.status).to eq :cancelled
      end
    end

    context 'on error' do
      before do
        EmailManager.stub_chain(:unretriable_cancel_to_admin, deliver: true)
        AmazonFlexPay.stub(:cancel_token) { raise AmazonFlexPay::API::Error.new(nil,nil,nil,nil) }
      end

      it 'updates contribution status' do
        contribution.cancel
        expect(contribution.reload.status).to eq :failure
      end

      it 'emails admin' do
        EmailManager.should_receive(:unretriable_cancel_to_admin).once
        contribution.cancel
      end

      it 'emails user' do
        EmailManager.should_receive(:contribution_cancelled).with(contribution).once
        contribution.cancel
      end
    end
  end

  describe "#execute_payment" do
    let(:contribution) { create :contribution }
    let(:project) { contribution.project }

    before do
      EmailManager.stub_chain(:contribution_successful, deliver: true)
    end

    before do
      AmazonFlexPay.stub(:pay).and_return(mock_response)
    end

    context 'on success' do
      let(:mock_response) do
        double("response", transaction_status: "Success", transaction_id: "abcdefg")
      end

      it 'updates contribution status' do
        contribution.execute_payment
        expect(contribution.reload.status).to eq :success
      end

      it 'sets retry count to 0' do
        contribution.execute_payment
        expect(contribution.reload.retry_count).to eq 0
      end

      it 'sets the transaction_id' do
        contribution.execute_payment
        expect(contribution.reload.transaction_id).to eq 'abcdefg'
      end

      it 'emails the user' do
        EmailManager.should_receive(:contribution_successful).with(contribution).once
        contribution.execute_payment
      end
    end

    context 'on pending' do
      let(:mock_response) do
        double("response", transaction_status: "Pending", transaction_id: "abcdefg")
      end

      it 'updates contribution status' do
        contribution.execute_payment
        expect(contribution.reload.status).to eq :pending
      end

      it 'sets retry count to 0' do
        contribution.execute_payment
        expect(contribution.reload.retry_count).to eq 0
      end

      it 'sets transaction id' do
        contribution.execute_payment
        expect(contribution.reload.transaction_id).to eq 'abcdefg'
      end
    end

    context 'on cancelled' do
      let(:mock_response) do
        double("response", transaction_status: "Cancelled", transaction_id: "abcdefg")
      end

      it 'on cancelled, updates contribution status' do
        EmailManager.stub_chain(:cancelled_payment_to_admin, deliver: true)

        EmailManager.should_receive(:cancelled_payment_to_admin).with(contribution).once

        contribution.execute_payment

        expect(contribution.status).to eq :cancelled
      end
    end

    context 'on error' do
      let(:mock_response) {nil}
      before do
        EmailManager.stub_chain(:unretriable_payment_to_admin, deliver: true)
        EmailManager.stub_chain(:unretriable_payment_to_user, deliver: true)
        AmazonFlexPay.stub(:pay) { raise AmazonFlexPay::API::Error.new(nil,nil,nil,nil) }
      end

      it 'updates contribution status' do
        contribution.execute_payment
        expect(contribution.reload.status).to eq :failure
      end

      it 'emails admin' do
        EmailManager.should_receive(:unretriable_payment_to_admin).once
        contribution.execute_payment
      end

      it 'emails user' do
        EmailManager.should_receive(:unretriable_payment_to_user).once
        contribution.execute_payment
      end
    end
  end

  describe "#update_status" do
    before do
      Amazon::FPS::TransactionStatusRequest.any_instance.stub(:send) {}
    end

    it 'on invalid response, e-mails admin error' do
      Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { false }
      Amazon::FPS::AmazonValidator.stub(:get_error) { create('email_both') }
      EmailManager.stub_chain(:failed_status_to_admin, deliver: true)
      contribution = create(:contribution, transaction_id: 'abcdefg')

      EmailManager.should_receive(:failed_status_to_admin).with(instance_of(AmazonError), contribution).once

      contribution.update_status
    end

    it 'on success, updates contribution status, sets retry count to 0, and sends e-mail to user' do
      Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { :success }
      Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }
      EmailManager.stub_chain(:contribution_successful, deliver: true)
      contribution = create(:contribution, transaction_id: 'abcdefg')

      EmailManager.should_receive(:contribution_successful).with(contribution).once

      contribution.update_status

      expect(contribution.status).to eq :success
      expect(contribution.retry_count).to eq 0
    end

    it 'on failure, updates contribution status and sends e-mail to user' do
      Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { :failure }
      Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }
      EmailManager.stub_chain(:failed_payment_to_user, deliver: true)
      contribution = create(:contribution, transaction_id: 'abcdefg')

      EmailManager.should_receive(:failed_payment_to_user).with(contribution).once

      contribution.update_status

      expect(contribution.status).to eq :failure
    end

    it 'on cancelled, updates contribution status and sends e-mail to admin' do
      Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { :cancelled }
      Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }
      EmailManager.stub_chain(:cancelled_payment_to_admin, deliver: true)
      contribution = create(:contribution, transaction_id: 'abcdefg')

      EmailManager.should_receive(:cancelled_payment_to_admin).with(contribution).once

      contribution.update_status

      expect(contribution.status).to eq :cancelled
    end

    it 'on pending, updates retry count' do
      Amazon::FPS::AmazonValidator.stub(:get_transaction_status) { :pending }
      Amazon::FPS::AmazonValidator.stub(:valid_transaction_status_response?) { true }

      contribution = create(:contribution, transaction_id: 'abcdefg', status: :pending, retry_count: 2)
      contribution.update_status

      expect(contribution.status).to eq :pending
      expect(contribution.retry_count).to eq 3
    end

  end

  describe "#destroy" do
    it 'calls cancel' do
      Contribution.any_instance.stub(:cancel) {}

      contribution = create(:contribution, transaction_id: 'abcdefg')
      contribution.should_receive(:cancel).once

      contribution.destroy
    end	
  end
end
