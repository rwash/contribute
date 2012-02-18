require 'spec_helper'

describe ProjectsController do
  include Devise::TestHelpers

	describe 'permissions' do
		context 'user is not signed in' do
			it "can view project" do
				project = FactoryGirl.create(:project)
				get :show, :id => project.name
				response.should be_success
				project.destroy
			end
			#I'm not sure why this test doesn't work
			it "can't view inactive project" do
				project = FactoryGirl.create(:project, :active => false)
				get :show, :id => project.name
				response.should redirect_to(root_path)	
				project.destroy
			end
			it "can't create a project" do
				get :new
				response.should redirect_to(new_user_session_path)	
			end
			it "can't edit a project" do
				project = FactoryGirl.create(:project)
				get :edit, :id => project.name
				response.should redirect_to(new_user_session_path)
				project.destroy
			end
		end

		context 'user is signed in' do
			user = FactoryGirl.create(:user)
			user.confirm!

			after(:all) do
				user.destroy
			end

			it 'can create a project' do
				sign_in user
				get :new
				response.should be_success
			end
			it "can't edit a project they don't own" do
				project = FactoryGirl.create(:project)
				sign_in user
				get :edit, :id => project.name
				response.should redirect_to(root_path)
				project.destroy
			end
			it "can edit a project they do own" do
				project = FactoryGirl.create(:project)
				project.user_id = user.id
				sign_in user
				get :edit, :id => project.name
				response.should redirect_to(root_path)
				project.destroy
			end
		end
	end
end
