require 'spec_helper'

describe ProjectsController do
  include Devise::TestHelpers

	describe 'permissions' do
		context 'user is not signed in' do
			it "can view project" do
				project = FactoryGirl.create(:project)
				get :show, :id => project.name
				response.should be_success
				project.delete
			end
			it "can't view inactive project" do
				project = FactoryGirl.create(:project, :active => false)
				get :show, :id => project.name
				response.should redirect_to(root_path)	
				project.delete
			end
			it "can't create a project" do
				get :new
				#new_user_session_path is the login page
				response.should redirect_to(new_user_session_path)	
			end
			it "can't destroy a project" do
				project = FactoryGirl.create(:project)
				get :destroy, :id => project.name
				response.should redirect_to(new_user_session_path)
				project.delete
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

			it 'can create a project' do
				sign_in @user
				get :new
				response.should be_success
			end
			it "can't destroy a project they don't own" do
				project = FactoryGirl.create(:project, user_id: @user.id + 1)
				sign_in @user
				get :destroy, :id => project.name
				assert flash[:alert].include?("not authorized"), flash[:alert]
				response.should redirect_to(root_path)
				project.delete
			end
			it "can destroy a project they do own" do
				project = FactoryGirl.create(:project, user_id: @user.id)
				sign_in @user
				get :destroy, :id => project.name
				assert flash[:alert].include?("successfully deleted"), flash[:alert]
				response.should redirect_to(root_path)
			end
		end
	end
end
