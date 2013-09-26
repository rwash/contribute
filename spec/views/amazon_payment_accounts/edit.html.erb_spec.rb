require 'spec_helper'

describe "amazon_payment_accounts/edit" do
  before(:each) do
    @amazon_payment_account = assign(:amazon_payment_account, stub_model(AmazonPaymentAccount))
  end

  it "renders the edit amazon_payment_account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => amazon_payment_accounts_path(@amazon_payment_account), :method => "post" do
    end
  end
end
