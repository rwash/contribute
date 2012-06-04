require 'spec_helper'
require 'controller_helper'

describe UpdatesController do
  include Devise::TestHelpers

	describe "functional tests:" do
		render_views

		before(:all) do
			@user = FactoryGirl.create(:user)
			@user.confirm!
			@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
		end

		after(:all) do
			@user.delete
			@project.delete
		end

		context "create action" do
			it 'can create an update' do
				sign_in @user
				get :new
				response.should be_success
			end
		end
		
	end
end
