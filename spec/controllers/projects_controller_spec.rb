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
				assert flash[:alert].include?("could not be deleted"), flash[:alert]
			end
		end

		context "save action" do
			before(:all) do
				@user = FactoryGirl.create(:user)
				@user.confirm!

				@project = FactoryGirl.create(:project, :user_id => @user.id, :confirmed => false)
			end
		
			before(:each) do
				@params = {"signature"=>"Vttw5Q909REPbf2YwvVn9DGAmz/rWQdKWSOj3tLxxYXBmCi7XvHSPgZGVAnNEo1O5SkSJavDod5j\n8XlUkZ99qn7CgqfAtOq0jnWEdmk4uYScfaHZNK6Xhw+KFCuTGBDn9tQoLVIpcXqRjds+aJ237Goh\n1J0btKmw1R363dFTLXA=", "refundTokenID"=>"C7Q3D4C4UP42186ADIE428XSRD3GCNBT1AN6E5TA43XF4QMDJSZNJD7RDQWGC5WV", "signatureVersion"=>"2", "signatureMethod"=>"RSA-SHA1", "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0o", "tokenID"=>"C5Q3L4H4UL4U18BA1IE12MXSDDAGCEBV1A56A5T243XF8QTDJQZ1JD9RFQW5CCWG", "status"=>"SR", "callerReference"=>"8cc8eb48-7ed8-4fb4-81f2-fe83389d58f5", "controller"=>"projects", "action"=>"save"}
				Amazon::FPS::AmazonValidator.stub(:valid_cbui_response?){true}
			end

			after(:all) do
				@project.delete
				@user.delete
			end

			it "should succeed with valid input" do
				sign_in @user
				session[:project_id] = @project.id
				get :save, @params
				response.should redirect_to(project_path(@project))
				assert flash[:alert].include?("saved successfully"), flash[:alert]
			end

			it "should handle unsuccessful input" do
				sign_in @user
				session[:project_id] = @project.id
				@params["status"] = "NP"
			
				get :save, @params
				response.should redirect_to(root_path)
				assert flash[:alert].include?("error"), flash[:alert]
			end

			it "should handle unsuccessful input case: 2" do
				Project.any_instance.stub(:save){false}
				sign_in @user
				session[:project_id] = @project.id
			
				get :save, @params
				response.should redirect_to(root_path)
				assert flash[:alert].include?("error"), flash[:alert]
			end
		end
	end
end
