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
				project = FactoryGirl.create(:project, :user_id => @user.id + 1)
				sign_in @user
				get :destroy, :id => project.name
				assert flash[:alert].include?("not authorized"), flash[:alert]
				response.should redirect_to(root_path)
				project.delete
			end
			it "can destroy a project they do own" do
				project = FactoryGirl.create(:project, :user_id => @user.id)
				sign_in @user
				get :destroy, :id => project.name
				assert flash[:alert].include?("successfully deleted"), flash[:alert]
				response.should redirect_to(root_path)
			end
		end
	end

	describe "functional tests:" do
		render_views

		context "index action" do
			it "should succeed" do
				get "index"
				response.should be_success
			end
		end

		context "create action" do
			before(:all) do
				UUIDTools::UUID.stub(:random_create){}

				@user = FactoryGirl.create(:user)
				@user.confirm!
			end

			after(:all) do
				@user.delete
			end

			it "should succeed for signed in user" do
				sign_in @user
				post 'create', :project => FactoryGirl.attributes_for(:project)

				request = Amazon::FPS::RecipientRequest.new(save_project_url)
				response.should redirect_to(request.url)
			end

			it "should fail for invalid project" do
				sign_in @user
				attributes = FactoryGirl.attributes_for(:project)
				attributes[:funding_goal] = -5
				post 'create', :project => attributes			
	
				response.should be_success
				response.body.inspect.include?("error").should be_true
				Project.find_by_name(attributes[:name]).should be_nil
			end
		end
		
		context "destroy action" do
			before(:all) do
				@project = FactoryGirl.create(:project)

				@user = FactoryGirl.create(:user)
				@user.confirm!

				@project.user_id = @user.id
				@project.save
			end

			after(:all) do
				@project.delete unless @project.nil?
				@user.delete
			end

			it "should succeed destroy" do
				sign_in @user
				delete :destroy, :id => @project.name

				response.should redirect_to(root_path)
				assert flash[:alert].include?("successfully deleted"), flash[:alert]
			end

			it "should handle failure" do
				Project.any_instance.stub(:destroy) {false}

				sign_in @user
				delete :destroy, :id => @project.name

				response.should redirect_to(project_path(@project))

				puts 'flash', flash[:alert]
				assert flash[:alert].include?("could not be deleted"), flash[:alert]
			end
		end
	end
end
