require 'spec_helper'
require 'integration_helper'

class AmazonFpsTesting
  describe "fps requests should" do

    let(:project) { Factory.create(:project, :state => 'active') }

    before :all do
      Project.delete_all
      Contribution.delete_all

      Capybara.default_driver = :selenium

      @headless = Headless.new
      @headless.start
    end

    after :all do
      Project.delete_all
      Contribution.delete_all

      delete_logs()
    end

    it "succeed on pay request and check transaction status" do
      contribution = generate_contribution(
        'thelen56@msu.edu', #contribution login
        'aaaaaa',
        'contribute_testing@hotmail.com', #amazon login
        'testing',
        project, #the project to contribute to
        100) #the amount

      request = Amazon::FPS::PayRequest.new(contribution.payment_key, contribution.project.payment_account_id, contribution.amount)
      response = request.send()

      response['Errors'].should be_nil
      response['PayResult']['TransactionStatus'].should_not be_nil

      transaction_id = response['PayResult']['TransactionId']
      transaction_id.should_not be_nil

      request = Amazon::FPS::GetTransactionStatusRequest.new(transaction_id)
      response = request.send()

      response['Errors'].should be_nil
      response['GetTransactionStatusResult']['TransactionStatus'].should_not be_nil
      Logging::LogPayResponse.find_by_TransactionId(transaction_id).should_not be_nil
      Logging::LogGetTransactionResponse.find_by_TransactionId(transaction_id).should_not be_nil
    end

    it "succeed on cancel token request" do
      contribution = generate_contribution(
        'thelen56@msu.edu', #contribution login
        'aaaaaa',
        'contribute_testing@hotmail.com', #amazon login
        'testing',
        project, #the project to contribute to
        100) #the amount

      request = Amazon::FPS::CancelTokenRequest.new(contribution.payment_key)
      response = request.send()

      response['Errors'].should be_nil

      log_cancel_request = Logging::LogCancelRequest.find_by_TokenId(contribution.payment_key)
      log_cancel_request.should_not be_nil
      Logging::LogCancelResponse.find_by_log_cancel_request_id(log_cancel_request.id).should_not be_nil
    end

    it "handle bad pay request" do
      request = Amazon::FPS::PayRequest.new('poop', 'poop', 50)
      response = request.send()

      log_pay_request = Logging::LogPayRequest.find_by_SenderTokenId('poop')
      log_pay_request.should_not be_nil
      assert_amazon_error(log_pay_request.id)
    end

    it "handle bad get transaction status request" do
      request = Amazon::FPS::GetTransactionStatusRequest.new('poop')
      response = request.send()

      log_get_transaction_request = Logging::LogGetTransactionRequest.find_by_TransactionId('poop')
      log_get_transaction_request.should_not be_nil
      assert_amazon_error(log_get_transaction_request.id)
    end

    it "handle bad cancel token request" do
      request = Amazon::FPS::CancelTokenRequest.new('poop')
      response = request.send()

      log_cancel_request = Logging::LogCancelRequest.find_by_TokenId('poop')
      log_cancel_request.should_not be_nil
      assert_amazon_error(log_cancel_request.id)
    end
  end
end
