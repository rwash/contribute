require 'spec_helper'

describe "amazon_payment_accounts/show" do
  before(:each) do
    @amazon_payment_account = assign(:amazon_payment_account, stub_model(AmazonPaymentAccount))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
