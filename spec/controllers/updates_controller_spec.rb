require 'spec_helper'
require 'controller_helper'

describe UpdatesController do
  include Devise::TestHelpers

	describe "functional tests:" do
		render_views

		before(:all) do
			@user = FactoryGirl.create(:user)
			@user2 = FactoryGirl.create(:user)
			
			@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
			@project2 = FactoryGirl.create(:project, :state => 'active', :user_id => @user2.id)
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
				flash[:notice].should == "Update saved succesfully."
			end
			
			it 'update should start with email_sent = false' do
				sign_in @user
				post 'create', :project_id => @project.id, :update => FactoryGirl.attributes_for(:update)
				response.should redirect_to(project_path(@project))
				Update.last.email_sent.should == false
			end
			
			it 'signed in user fails for incomplete update' do
				sign_in @user
				post 'create', :project_id => @project.id
				response.should redirect_to(project_path(@project))
				flash[:error].should include "Update failed to save."
			end
			
			it 'fails for not signed in user' do
				post 'create', :project_id => @project.id, :update => FactoryGirl.attributes_for(:update)
				response.should redirect_to(project_path(@project))
				flash[:error].should include "You cannot update this project."
			end
			
			it 'fails for user who is not project owner' do
				post 'create', :project_id => @project2.id, :update => FactoryGirl.attributes_for(:update)
				response.should redirect_to(project_path(@project2))
				flash[:error].should include "You cannot update this project."
			end
		end	
	end
end
