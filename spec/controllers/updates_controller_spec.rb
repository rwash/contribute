require 'spec_helper'
require 'controller_helper'

describe UpdatesController do
  include Devise::TestHelpers

	describe "functional tests:" do
		render_views

		before(:all) do
			@user = FactoryGirl.create(:user)
			@user.confirm!
			@user2 = FactoryGirl.create(:user2)
			@user2.confirm!
			
			@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
			@project2 = FactoryGirl.create(:project2, :state => 'active', :user_id => @user2.id)
		end

		after(:all) do
			@user.delete
			@user2.delete
			@project.delete
			@project2.delete
		end

		context "create action" do
			it 'signed in user can create an update' do
				sign_in @user
				post 'create', :project_id => @project.id, :update => FactoryGirl.attributes_for(:update)
				response.should redirect_to(project_path(@project))
				assert flash[:notice].include?("Update saved succesfully."), "Should succeed (and show succesfull notice)"
			end
			
			it 'update should start with email_sent = false' do
				sign_in @user
				post 'create', :project_id => @project.id, :update => FactoryGirl.attributes_for(:update)
				response.should redirect_to(project_path(@project))
				assert Update.last.email_sent == false, "email_sent value was not set to false."
			end
			
			it 'signed in user fails for incomplete update' do
				sign_in @user
				post 'create', :project_id => @project.id
				response.should redirect_to(project_path(@project))
				assert flash[:error].include?("Update failed to save."), "Should fail for incomplete update. (and show error msg)"
			end
			
			it 'fails for not signed in user' do
				post 'create', :project_id => @project.id, :update => FactoryGirl.attributes_for(:update)
				response.should redirect_to(project_path(@project))
				assert flash[:error].include?("You must be logged in and be the project owner to post an update."), "Should fail if user is not signed in."
			end
			
			it 'fails for user who is not project owner' do
				post 'create', :project_id => @project2.id, :update => FactoryGirl.attributes_for(:update)
				response.should redirect_to(project_path(@project2))
				assert flash[:error].include?("You must be logged in and be the project owner to post an update."), "Should fail if user is not proj owner."
			end
		end	
	end
end
