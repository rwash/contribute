require "spec_helper"

describe AmazonPaymentAccountsController do
  describe "routing" do

    it "routes to #new" do
      get("/projects/Project-1/amazon_payment_accounts/new").should route_to(
        "amazon_payment_accounts#new",
        project_id: 'Project-1')
    end

    it "routes to #create" do
      post("/projects/Project-1/amazon_payment_accounts").should route_to(
        "amazon_payment_accounts#create",
        project_id: 'Project-1')
    end

    it "routes to #destroy" do
      delete("/projects/Project-1/amazon_payment_accounts/1").should route_to(
        "amazon_payment_accounts#destroy",
        :id => "1",
        project_id: 'Project-1')
    end

  end
end
