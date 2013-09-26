require 'spec_helper'

describe "amazon_payment_accounts/new" do
  before(:each) do
    assign(:amazon_payment_account, stub_model(AmazonPaymentAccount).as_new_record)
  end

  it "renders new amazon_payment_account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => amazon_payment_accounts_path, :method => "post" do
    end
  end
end
