require "spec_helper"

describe AmazonPaymentAccountsController do
  describe "routing" do

    it "routes to #index" do
      get("/amazon_payment_accounts").should route_to("amazon_payment_accounts#index")
    end

    it "routes to #new" do
      get("/amazon_payment_accounts/new").should route_to("amazon_payment_accounts#new")
    end

    it "routes to #show" do
      get("/amazon_payment_accounts/1").should route_to("amazon_payment_accounts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/amazon_payment_accounts/1/edit").should route_to("amazon_payment_accounts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/amazon_payment_accounts").should route_to("amazon_payment_accounts#create")
    end

    it "routes to #update" do
      put("/amazon_payment_accounts/1").should route_to("amazon_payment_accounts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/amazon_payment_accounts/1").should route_to("amazon_payment_accounts#destroy", :id => "1")
    end

  end
end
