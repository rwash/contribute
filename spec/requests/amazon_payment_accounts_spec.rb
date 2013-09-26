require 'spec_helper'

describe "AmazonPaymentAccounts" do
  describe "GET /amazon_payment_accounts" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get amazon_payment_accounts_path
      response.status.should be(200)
    end
  end
end
