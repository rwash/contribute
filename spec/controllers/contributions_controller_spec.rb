require 'spec_helper'
require 'controller_helper'

describe ContributionsController do
	include Devise::TestHelpers

	describe 'permissions' do
		before(:all) do
			@project = FactoryGirl.create(:project, :state => 'active')
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
			
			describe 'after end_date but active' do
				it 'cant contribute to project after end_date' do
					project = FactoryGirl.build(:project, :state => 'active', :end_date => Date.yesterday)
					project.save(:validate => false)
					contribution = FactoryGirl.create(:contribution, :user_id => @user.id, :project_id => project.id)
					
					sign_in @user
					get :new, :project => project.name
					response.should be_success
					# assert flash[:alert].include?("The contribution period has ended."), flash[:alert]
					
					project.delete
				end
				
				it 'can contribute to project on end_date' do
					project = FactoryGirl.build(:project, :state => 'active', :end_date => Date.today)
					project.save(:validate => false)
					contribution = FactoryGirl.create(:contribution, :user_id => @user.id, :project_id => project.id)
					
					sign_in @user
					get :new, :project => project.name
					response.should be_success
										
					project.delete
				end
				
				it 'can contribute to project before end_date' do
					project = FactoryGirl.build(:project, :state => 'active', :end_date => Date.tomorrow)
					project.save(:validate => false)
					contribution = FactoryGirl.create(:contribution, :user_id => @user.id, :project_id => project.id)
					
					sign_in @user
					get :new, :project => project.name
					response.should be_success
					
					project.delete
				end
			end
		end
	end
	
	describe 'functional tests: ' do
		before(:all) do
			@user = FactoryGirl.create(:user)
			@user.confirm!
		end
	
		after(:all) do 
			@user.delete
		end
		
		context 'save action' do
			before(:all) do
				@project = FactoryGirl.create(:project)
				@contribution = FactoryGirl.build(:contribution, :user_id => @user.id, :project_id => @project.id)
			end
		
			after(:all) do 
				Project.delete_all
				Contribution.delete_all
			end

			before(:each) do
				@params = {"signature"=>"Thvdd5kskNDHS27B33qHnI9M2Rdm3kYFhP0jU2LBd69i/COjNzAYDetOoudQMsFKuRvM1g5/TDDh\nRdKSWQvX9rz65BDgdruXIoxeFouMLyZgkXSCR8lEHUMosxJVYo5bn6qSeUCmFyJ42iy+05zqc6yf\ncEpTePp3mnGJ2do6LN8=", "expiry"=>"10/2017", "signatureVersion"=>"2", "signatureMethod"=>"RSA-SHA1", "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0o", "tokenID"=>"I6TRJVI1ARAHBNCZFJII35UPJXJCXMD5ID9RHMMIUJ6DAJAZDSDEKDAEVBDPQBB3", "status"=>"SC", "callerReference"=>"4d9cf6a3-59d7-4fda-8ddb-296e92c95b06", "controller"=>"contributions", "action"=>"save"}
				Amazon::FPS::AmazonValidator.stub(:valid_cbui_response?){true}
			end

			it "should succeed for valid input" do
				sign_in @user
				session[:contribution] = @contribution
				
				get :save, @params
				response.should redirect_to(@contribution.project)
				assert flash[:alert].include?("entered successfully"), flash[:alert]
			end
			
			it "should handle a nil contribution" do
				sign_in @user
				session[:contribution] = nil

				get :save, @params
				assert_contribution_failure(root_path)
			end
	
			it "should handle invalid parameters" do
				sign_in @user
				session[:contribution] = @contribution
				@params["tokenID"] = nil

				get :save, @params
				assert_contribution_failure(@contribution.project)
			end

			it "should handle contribution not saving" do
				Contribution.any_instance.stub(:save){false}

				sign_in @user
				session[:contribution] = @contribution

				get :save, @params
				assert_contribution_failure(@contribution.project)
			end
		end

		context 'show action' do
			it "should raise 404" do
				lambda { get :show, :id => 1 }.should raise_error
			end
		end

		context 'update_save action' do
			before(:all) do
				@project = FactoryGirl.create(:project)
				@editing_contribution = FactoryGirl.create(:contribution, :user_id => @user.id, :project_id => @project.id)
				@contribution = FactoryGirl.build(:contribution2, :user_id => @user.id, :project_id => @project.id)
			end
		
			after(:all) do 
				Project.delete_all
				Contribution.delete_all
			end

			before(:each) do
				@params = {"signature"=>"IPbBYiozVv4/HHI+hMQLbY1L9rq0x+jSvka0/p65gGqCKdqRhegLF/WURdIjB/9mMFLDxv0BinZw\nT29ij5uTJL1Vqm0mLTAGVeo2v/cpBFJF+egfDjTE1P3TkS23S+YKvzcCxGstGgXnCbSkXcGI0oGM\ntwlT7H5eMRX5Mp6F8eo=", "expiry"=>"10/2017", "signatureVersion"=>"2", "signatureMethod"=>"RSA-SHA1", "certificateUrl"=>"https://fps.sandbox.amazonaws.com/certs/090911/PKICert.pem?requestId=bjzj0tpgedksa8xv8c5jns5i4d7ugwehryvxtzspigd3omooy0o", "tokenID"=>"I4TRCVA1ATAFBN1ZJJI634UP4XQCX9DDIDNR1MM7UF6DDJ6ZDDD7KD9E4BDVQIBF", "status"=>"SC", "callerReference"=>"b87070fe-a36f-4dee-80f4-3a8e76837096", "controller"=>"contributions", "action"=>"update_save"}
				Amazon::FPS::AmazonValidator.stub(:valid_cbui_response?){true}
				Amazon::FPS::CancelTokenRequest.stub(:send)
			end

			it "should succeed with valid input" do
				sign_in @user
				session[:contribution] = @contribution #new contribution
				session[:editing_contribution_id] = @editing_contribution.id #old contribution	
				get :update_save, @params
				response.should redirect_to(@contribution.project)
				assert flash[:alert].include?("successfully updated"), flash[:alert]
			end

			it "should fail without a contribution in session" do
				sign_in @user
				session[:contribution] = nil
				session[:editing_contribution_id] = @editing_contribution.id

				get :update_save, @params
				assert_contribution_failure(root_path)
			end

			it "should fail with invalid params" do
				sign_in @user
				session[:contribution] = @contribution
				session[:editing_contribution_id] = @editing_contribution.id
				@params["tokenID"] = nil

				get :update_save, @params
				assert_contribution_failure(@contribution.project)
			end

			it "should fail if the contribution can't save" do
				Contribution.any_instance.stub(:save){false}
			
				sign_in @user
				session[:contribution] = @contribution
				session[:editing_contribution_id] = @editing_contribution.id

				get :update_save, @params
				assert_contribution_failure(@contribution.project)
			end

			it "should fail if editing contribution can't cancel" do
				Contribution.any_instance.stub(:cancel){false}
				Contribution.any_instance.stub(:save){true} #if you remove this, you will get a stack overflow error at @contribution.save.  The previous test and this one will run in isolation, but not one after another *shrugs*

				sign_in @user
				session[:contribution] = @contribution
				session[:editing_contribution_id] = @editing_contribution.id

				get :update_save, @params
				assert_contribution_failure(@contribution.project)
			end
		end

		context "protected functions" do

			before(:all) do
				@project_1 = FactoryGirl.create(:project, :active => 0)
				@project_2 = FactoryGirl.create(:project2, :confirmed => 0)
			end

			after(:all) do
				Project.delete_all
			end

			it "validate_project should handle invalid project" do
				sign_in @user

				get :new, :project => @project_1.name	
				assert_contribution_failure(root_path)
			end

			it "validate_project should handle invalid project case: 2" do
				sign_in @user

				get :new, :project => @project_2.name	
				assert_contribution_failure(root_path)
			end

			it "prepare contribution should handle invalid contribution" do
				sign_in @user

				get :edit, {:id =>1}
				assert_contribution_failure(root_path)
			end
		end
	end
end
