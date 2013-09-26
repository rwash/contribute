require 'spec_helper'

describe "amazon_payment_accounts/index" do
  before(:each) do
    assign(:amazon_payment_accounts, [
      stub_model(AmazonPaymentAccount),
      stub_model(AmazonPaymentAccount)
    ])
  end

  it "renders a list of amazon_payment_accounts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
