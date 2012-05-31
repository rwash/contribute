require 'spec_helper'
require 'controller_helper'

describe UpdatesController do
=begin
  include Devise::TestHelpers

	describe "functional tests:" do
		render_views

		before(:all) do
			@user = FactoryGirl.create(:user)
			@user.confirm!
			@project = FactoryGirl.create(:project)
		end

		after(:all) do
			@user.delete
			@project.delete
		end

		context "create action" do

			it "should succeed for signed in user" do
				sign_in @user
				post 'create', FactoryGirl.create(:update, :title => "Hey", :content => "hey Hey", :project_id => 1, :user_id => @user.id)
				
				response.should be_success
				response.body.inspect.include?("notice").should be_true
			end

			it "should fail for invalid update" do
				sign_in @user
				attributes = FactoryGirl.attributes_for(:update)
				attributes[:title] = ''
				post 'create', :update => attributes			
	
				response.should be_success
				response.body.inspect.include?("error").should be_true
			end
		end
		
	end
=end
end
