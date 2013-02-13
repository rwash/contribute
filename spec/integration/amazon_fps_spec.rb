require 'spec_helper'
require 'integration_helper'

class AmazonFpsTesting
  describe "fps requests should" do
    let(:project) { create(:project, state: :active) }

    before :all do
      Capybara.default_driver = :selenium

      @headless = Headless.new
      @headless.start
    end

    let(:user) { create :user }

    it "succeed on pay request and check transaction status" do
      contribution = generate_contribution(
        user, #contribution login
        'contribute_testing@hotmail.com', #amazon login
        'testing',
        project, #the project to contribute to
        100) #the amount

      request = Amazon::FPS::PayRequest.new(contribution.payment_key, contribution.project.payment_account_id, contribution.amount)
      response = request.send()

      expect(response['Errors']).to be_nil
      expect(response['PayResult']['TransactionStatus']).to_not be_nil

      transaction_id = response['PayResult']['TransactionId']
      expect(transaction_id).to_not be_nil

      request = Amazon::FPS::GetTransactionStatusRequest.new(transaction_id)
      response = request.send()

      expect(response['Errors']).to be_nil
      expect(response['GetTransactionStatusResult']['TransactionStatus']).to_not be_nil
      expect(Logging::LogPayResponse.find_by_TransactionId(transaction_id)).to_not be_nil
      expect(Logging::LogGetTransactionResponse.find_by_TransactionId(transaction_id)).to_not be_nil
    end

    it "succeed on cancel token request" do
      contribution = generate_contribution(
        user, #contribution login
        'contribute_testing@hotmail.com', #amazon login
        'testing',
        project, #the project to contribute to
        100) #the amount

      request = Amazon::FPS::CancelTokenRequest.new(contribution.payment_key)
      response = request.send()

      expect(response['Errors']).to be_nil

      log_cancel_request = Logging::LogCancelRequest.find_by_TokenId(contribution.payment_key)
      expect(log_cancel_request).to_not be_nil
      expect(Logging::LogCancelResponse.find_by_log_cancel_request_id(log_cancel_request.id)).to_not be_nil
    end

    it "handle bad pay request" do
      request = Amazon::FPS::PayRequest.new('poop', 'poop', 50)
      request.send()

      log_pay_request = Logging::LogPayRequest.find_by_SenderTokenId('poop')
      expect(log_pay_request).to_not be_nil
      assert_amazon_error(log_pay_request.id)
    end

    it "handle bad get transaction status request" do
      request = Amazon::FPS::GetTransactionStatusRequest.new('poop')
      request.send()

      log_get_transaction_request = Logging::LogGetTransactionRequest.find_by_TransactionId('poop')
      expect(log_get_transaction_request).to_not be_nil
      assert_amazon_error(log_get_transaction_request.id)
    end

    it "handle bad cancel token request" do
      request = Amazon::FPS::CancelTokenRequest.new('poop')
      request.send()

      log_cancel_request = Logging::LogCancelRequest.find_by_TokenId('poop')
      expect(log_cancel_request).to_not be_nil
      assert_amazon_error(log_cancel_request.id)
    end
  end
end
