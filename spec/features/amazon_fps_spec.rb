require 'spec_helper'
require 'integration_helper'

feature "fps requests should", :js do
  let(:project) { create(:active_project) }

  let(:user) { create :user }

  scenario "succeed on pay request" do
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
  end

  scenario "succeed on cancel token request" do
    contribution = generate_contribution(
      user, #contribution login
      'contribute_testing@hotmail.com', #amazon login
      'testing',
      project, #the project to contribute to
      100) #the amount

    response = nil
    expect do
      response = AmazonFlexPay.cancel_token(contribution.payment_key)
    end.to_not raise_error

    puts "Response: #{response.inspect}"
    puts "Response methods: #{response.public_methods}"

    pending "Log requests and responses!"
    log_cancel_request = Logging::LogCancelRequest.find_by_TokenId(contribution.payment_key)
    expect(log_cancel_request).to_not be_nil
    expect(Logging::LogCancelResponse.find_by_log_cancel_request_id(log_cancel_request.id)).to_not be_nil
  end

  scenario "handle invalid pay request" do
    request = Amazon::FPS::PayRequest.new('invalid', 'invalid', 50)
    request.send()

    log_pay_request = Logging::LogPayRequest.find_by_SenderTokenId('invalid')
    expect(log_pay_request).to_not be_nil
    assert_amazon_error(log_pay_request.id)
  end
end
