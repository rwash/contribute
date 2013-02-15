require "spec_helper"

describe ListingsController do
  describe "routing" do

    it "routes to #destroy" do
      delete("/projects/1").should route_to("projects#destroy", :id => "1")
    end

    it "routes to #sort" do
      post("listings/sort").should route_to("listings#sort")
    end
  end
end
