require 'spec_helper'

describe ContributionsController do
	include Devise::TestHelpers

	describe 'permissions' do
		before(:all) do
			@project = FactoryGirl.create(:project)
		end

		after(:all) do
			Project.delete_all
			Contribution.delete_all
		end

		context 'user is not signed in' do
			it "can't contribute to project" do
				get :new, :project => @project.id
				response.should redirect_to(new_user_session_path)
			end	
		end

		context 'user is signed in' do
      before(:all) do
				@user = FactoryGirl.create(:user)
				@user.confirm!
			end
		
			after(:all) do 
				@user.delete
			end

			it "can contribute to project" do
				sign_in @user
				get :new, :project => @project.name
				response.should be_success
			end

			it "can't contribute twice" do
				contribution = FactoryGirl.create(:contribution, :user_id => @user.id, :project_id => @project.id)
				sign_in @user
				get :new, :project => @project.name
				response.should redirect_to(@project)
				assert flash[:alert].include?("may not contribute"), flash[:alert]
			end		

			it "can edit contribution" do
				contribution = FactoryGirl.create(:contribution, :user_id => @user.id, :project_id => @project.id)
				sign_in @user
				get :edit, :id => contribution.id
				response.should be_success
			end

			it "can't edit someone else's contribution" do
				contribution = FactoryGirl.create(:contribution, :user_id => @user.id + 1, :project_id => @project.id)
				sign_in @user
				get :edit, :id => contribution.id
				response.should redirect_to(@project)
				assert flash[:alert].include?("may not edit this contribution"), flash[:alert]
			end
		end
	end
end
