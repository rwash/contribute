require 'spec_helper'
require 'controller_helper'

describe ProjectsController do
  include Devise::TestHelpers

	describe 'permissions' do
		context 'user is not signed in' do
			it "can view project" do
				project = FactoryGirl.create(:project, :state => 'active')
				get :show, :id => project.name
				response.should be_success
				project.delete
			end
			it "can't view inactive project" do
				project = FactoryGirl.create(:project, :state => 'inactive')
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
			
			# Start State Tests (These tests are added after those above. Some of the ones below may cover the same thing as one above.)
			context 'project is unconfirmed,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[0])
				end

				after(:all) do
					@project.delete
				end
				
				it 'can NOT view project' do
					get :show, :id => @project.name
					response.should redirect_to(root_path)
				end
				
				it "can't destroy a project" do
					get :destroy, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
				
				it "can't edit a project" do
					get :edit, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
			end
			
			context 'project is inactive,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[1])
				end

				after(:all) do
					@project.delete
				end
				
				it 'can NOT view project' do
					get :show, :id => @project.name
					response.should redirect_to(root_path)
				end
				
				it "can't destroy a project" do
					get :destroy, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
				
				it "can't edit a project" do
					get :edit, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
			end
			
			context 'project is active,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[2])
				end

				after(:all) do
					@project.delete
				end
				
				it 'CAN view project' do
					get :show, :id => @project.name
					response.should be_success
				end
				
				it "can't destroy a project" do
					get :destroy, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
				
				it "can't edit a project" do
					get :edit, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
			end
			
			context 'project is funded,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[4])
				end

				after(:all) do
					@project.delete
				end
				
				it 'CAN view project' do
					get :show, :id => @project.name
					response.should be_success
				end
				
				it "can't destroy a project" do
					get :destroy, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
				
				it "can't edit a project" do
					get :edit, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
			end
			
			context 'project is nonfunded,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[3])
				end

				after(:all) do
					@project.delete
				end
				
				it 'CAN view project' do
					get :show, :id => @project.name
					response.should be_success
				end
				
				it "can't destroy a project" do
					get :destroy, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
				
				it "can't edit a project" do
					get :edit, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
			end
			
			context 'project is canceled,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[5])
				end

				after(:all) do
					@project.delete
				end
				
				it 'can NOT view project' do
					get :show, :id => @project.name
					response.should redirect_to(root_path)
				end
				
				it "can't destroy a project" do
					get :destroy, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
				
				it "can't edit a project" do
					get :edit, :id => @project.name
					response.should redirect_to(new_user_session_path)
				end
			end
		end

		context 'user is signed in' do #START user IS signed in
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
				flash[:alert].should include "not authorized"
				response.should redirect_to(root_path)
				project.delete
			end
			it "can destroy a project they do own" do
				project = FactoryGirl.create(:project, :user_id => @user.id, :state => PROJ_STATES[1])
				sign_in @user
				get :destroy, :id => project.name
				flash[:alert].should include "successfully deleted"
				response.should redirect_to(root_path)
			end
			
			#Again the tests below were added after those above and may test some of the same thing.
			context 'project is unconfirmed,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[0])
				end

				after(:all) do
					@project.delete
				end
				
				context 'user is NOT project owner' do
					before(:all) do
						@project.user_id = @user.id + 1
					end
				
					it 'can NOT view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should redirect_to(root_path)
					end
					
					it "can't destroy a project" do
						sign_in @user
						get :destroy, :id => @project.name
						Project.find(@project.id).should_not be_nil
						response.should redirect_to(root_path)
					end
					
					it "can't edit a project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should redirect_to(root_path)
					end
				end
				
				context 'user IS project owner' do
					before(:all) do
						@project.user_id = @user.id
						@project.save!
					end
				
					it 'CAN view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should be_success
					end
					
					it "CAN destroy a project" do
						sign_in @user
						get :destroy, :id => @project.name
						flash[:alert].should include "successfully deleted"
						response.should redirect_to(root_path)
					end
					
					it "CAN edit the project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should be_success
					end
				end
			end
			
			context 'project is inactive,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[1])
				end

				after(:all) do
					@project.delete
				end
				
				context 'user is NOT project owner' do
					before(:all) do
						@project.user_id = @user.id + 1
					end
				
					it 'can NOT view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should redirect_to(root_path)
					end
					
					it "can't destroy a project" do
						sign_in @user
						get :destroy, :id => @project.name
						Project.find(@project.id).should_not be_nil
						response.should redirect_to(root_path)
					end
					
					it "can't edit a project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should redirect_to(root_path)
					end
				end
				
				context 'user IS project owner' do
					before(:all) do
						@project.user_id = @user.id
						@project.save!
					end
				
					it 'CAN view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should be_success
					end
					
					it "CAN destroy a project" do
						sign_in @user
						get :destroy, :id => @project.name
						flash[:alert].should include "successfully deleted"
						response.should redirect_to(root_path)
					end
					
					it "CAN edit the project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should be_success
					end
				end
			end
			
			context 'project is active,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[2])
				end

				after(:all) do
					@project.delete
				end
				
				context 'user is NOT project owner' do
					before(:all) do
						@project.user_id = @user.id + 1
					end
					
					it 'CAN view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should be_success
					end
					
					it "can't destroy a project" do
						sign_in @user
						get :destroy, :id => @project.name
						Project.find(@project.id).should_not be_nil
						response.should redirect_to(root_path)
					end
					
					it "can't edit a project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should redirect_to(root_path)
					end
				end
				
				context 'user IS project owner' do
					before(:all) do
						@project.user_id = @user.id
						@project.save!
					end
				
					it 'CAN view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should be_success
					end
					
					it "CAN cancel a project" do
						sign_in @user
						get :destroy, :id => @project.name
						flash[:alert].should include "Project successfully canceled."
						response.should redirect_to(root_path)
					end
					
					it "can't edit the project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should redirect_to(root_path)
					end
				end
			end
			
			context 'project is funded,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[4])
				end

				after(:all) do
					@project.delete
				end
				
				context 'user is NOT project owner' do
					before(:all) do
						@project.user_id = @user.id + 1
					end
				
					it 'CAN view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should be_success
					end
					
					it "can't destroy the project" do
						sign_in @user
						get :destroy, :id => @project.name
						Project.find(@project.id).should_not be_nil
						response.should redirect_to(root_path)
					end
					
					it "can't edit the project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should redirect_to(root_path)
					end
				end
				
				context 'user IS project owner' do
					before(:all) do
						@project.user_id = @user.id
						@project.save!
					end
				
					it 'CAN view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should be_success
					end
					
					it "can NOT cancel or delete a project" do
						sign_in @user
						get :destroy, :id => @project.name
						flash[:alert].should include "You can not cancel or delete this project."
						response.should redirect_to(root_path)
					end
					
					it "can't edit the project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should redirect_to(root_path)
					end
				end
			end
			
			context 'project is nonfunded,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[3])
				end

				after(:all) do
					@project.delete
				end
				
				context 'user is NOT project owner' do
					before(:all) do
						@project.user_id = @user.id + 1
					end
					
					it 'CAN view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should be_success
					end
					
					it "can't destroy a project" do
						sign_in @user
						get :destroy, :id => @project.name
						Project.find(@project.id).should_not be_nil
						response.should redirect_to(root_path)
					end
					
					it "can't edit the project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should redirect_to(root_path)
					end
				end
				
				context 'user IS project owner' do
					before(:all) do
						@project.user_id = @user.id
						@project.save!
					end
				
					it 'CAN view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should be_success
					end
					
					it "can NOT cancel or delete a project" do
						sign_in @user
						get :destroy, :id => @project.name
						flash[:alert].should include "You can not cancel or delete this project."
						response.should redirect_to(root_path)
					end
					
					it "can't edit the project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should redirect_to(root_path)
					end
				end
			end
			
			context 'project is canceled,' do
				before(:all) do
					@project = FactoryGirl.create(:project, :state => PROJ_STATES[5])
				end

				after(:all) do
					@project.delete
				end
				
				context 'user is NOT project owner' do
					before(:all) do
						@project.user_id = @user.id + 1
						@project.save!
					end
				
					it 'can NOT view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should redirect_to(root_path)
					end
					
					it "can't destroy a project" do
						sign_in @user
						get :destroy, :id => @project.name
						Project.find(@project.id).should_not be_nil
						response.should redirect_to(root_path)
					end
					
					it "can't edit the project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should redirect_to(root_path)
					end
				end
				
				context 'user IS project owner' do
					before(:all) do
						@project.user_id = @user.id
						@project.save!
					end
				
					it 'CAN view project' do
						sign_in @user
						get :show, :id => @project.name
						response.should be_success
					end
					
					it "can NOT cancel or delete a project" do
						sign_in @user
						get :destroy, :id => @project.name
						flash[:alert].should include "You can not cancel or delete this project."
						response.should redirect_to(root_path)
					end
					
					it "can't edit the project" do
						sign_in @user
						get :edit, :id => @project.name
						response.should redirect_to(root_path)
					end
				end

			end
		end
	end

	describe "functional tests:" do
		render_views

		before(:all) do
			@user = FactoryGirl.create(:user)
		end

		after(:all) do
			@user.delete
		end

		context "index action" do
			it "should succeed" do
				get "index"
				response.should be_success
			end
		end

		context "create action" do
			before(:all) do
				UUIDTools::UUID.stub(:random_create){}
			end

			it "should succeed for signed in user" do
				sign_in @user
				post 'create', project: Factory.attributes_for(:project)

				request = Amazon::FPS::RecipientRequest.new(save_project_url)
				response.should redirect_to(request.url)
			end

			it "should fail for invalid project" do
				sign_in @user
				invalid_attributes = Factory.attributes_for(:project, funding_goal: -5)
				post 'create', project: invalid_attributes
	
				response.should be_success
				response.body.inspect.should include("error")
				Project.find_by_name(invalid_attributes[:name]).should be_nil
			end
		end
		
		context "destroy action" do
			before(:all) do
				@project = FactoryGirl.create(:project, :user_id => @user.id, :state => PROJ_STATES[1])
			end

			after(:all) do
				Project.delete_all
			end

			it "should succeed destroy" do
				sign_in @user
				delete :destroy, :id => @project.name

				response.should redirect_to(root_path)
				flash[:alert].should include "successfully deleted"
			end

			it "should handle failure" do
				Project.any_instance.stub(:destroy) {false}

				sign_in @user
				delete :destroy, :id => @project.name

				response.should redirect_to(project_path(@project))
				flash[:alert].should include "could not be deleted"
			end
		end

		context "save action" do
			before(:all) do
				@project = FactoryGirl.create(:project, :user_id => @user.id, :state => 'unconfirmed')
			end
		
			before(:each) do
				@params = {"signature"=>"Vttw5Q909REPbf2YwvVn9DGAmz/rWQdKWSOj3tLxxYXBmCi7XvHSPgZGVAnNEo1O5SkSJavDod5j\n8XlUkZ99qn7CgqfAtOq0jnWEdmk4uYScfaHZNK6Xhw+KFCuTGBDn9tQoLVIpcXqRjds+aJ237Goh\n1J0btKmw1R363dFTLXA=", "refundTokenID"=>"C7Q3D4C4UP42186ADIE428XSRD3GCNBT1AN6E5TA43XF4QMDJSZNJD7RDQWGC5WV", "signatureVersion"=>"2", "signatureMethod"=>"RSA-SHA1", "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0o", "tokenID"=>"C5Q3L4H4UL4U18BA1IE12MXSDDAGCEBV1A56A5T243XF8QTDJQZ1JD9RFQW5CCWG", "status"=>"SR", "callerReference"=>"8cc8eb48-7ed8-4fb4-81f2-fe83389d58f5", "controller"=>"projects", "action"=>"save"}
				Amazon::FPS::AmazonValidator.stub(:valid_cbui_response?){true}
			end

			after(:all) do
				Project.delete_all
			end

			it "should succeed with valid input" do
				sign_in @user
				session[:project_id] = @project.id
				get :save, @params
				# response.should redirect_to(project_path(@project))
				response.should redirect_to(@project)
				flash[:alert].should include "saved successfully"
			end

			it "should handle unsuccessful input" do
				sign_in @user
				session[:project_id] = @project.id
				@params["status"] = "NP"
			
				get :save, @params
				response.should redirect_to(root_path)
				flash[:alert].should include "error"
			end

			it "should handle unsuccessful input case: 2" do
				Project.any_instance.stub(:save){false}
				sign_in @user
				session[:project_id] = @project.id
			
				get :save, @params
				response.should redirect_to(root_path)
				flash[:alert].should include "error"
			end
		end
	end
end
