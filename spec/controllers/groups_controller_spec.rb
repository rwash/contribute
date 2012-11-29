require 'spec_helper'
require 'controller_helper'

describe GroupsController do
  include Devise::TestHelpers
  
	describe "functional tests:" do
		render_views
	
		before(:all) do
			@user = FactoryGirl.create(:user)
			@user.confirm!
		end
	
		after(:all) do
			@user.delete
		end
		
		context "creating groups" do
			it "signed in user can create group" do
				sign_in @user
				post 'create', :group => FactoryGirl.attributes_for(:group)
				flash[:notice].should include "Successfully created group."
			end
			
			it "not signed in user cannont create group" do
				post 'create', :group => FactoryGirl.attributes_for(:group)
				response.should redirect_to('/users/sign_in')
				flash[:alert].should include "You need to sign in or sign up before continuing."
			end
			
			it "admin can edit group" do
				sign_in @user
				@group = FactoryGirl.create(:group, :open => true, :admin_user_id => @user.id)
				
				get 'edit', :id => @group.id
				response.should be_success
			end
			
			it "non admin can not edit group" do
				sign_in @user
				@group = FactoryGirl.create(:group, :open => true, :admin_user_id => @user.id + 1)
				
				get 'edit', :id => @group.id
				flash[:alert].should include "You are not authorized to access this page."
			end
		end
		
		context "destroy groups" do
			it "not signed in user cannot delete group" do
				@group = FactoryGirl.create(:group, :open => true, :admin_user_id => 19)
				
				get 'destroy', :id => @group.id
				flash[:alert].should include "You are not authorized to access this page."
			end
			it "signed in user cannot delete group it doesnt own" do
				sign_in @user
				@group = FactoryGirl.create(:group, :open => true, :admin_user_id => @user.id + 1)
				
				get 'destroy', :id => @group.id
				flash[:alert].should include "You are not authorized to access this page."
			end
			it "signed in user can delete groups it is admin of" do
				sign_in @user
				@group = FactoryGirl.create(:group, :open => true, :admin_user_id => @user.id)
				
				get 'destroy', :id => @group.id
				response.should redirect_to(groups_path)
			end
		end
		
		#
		#open groups
		#
		
		context "adding projects to open group" do
			before(:all) do
				@group = FactoryGirl.create(:group, :open => true, :admin_user_id => @user.id)
			end
			
			after(:all) do
				@group.delete
			end
			
			it 'can add unconfirmed project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'unconfirmed', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:notice].should include "Your project has been added to the group."
			end
			
			it 'can add inactive project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'inactive', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:notice].should include "Your project has been added to the group."
			end
			it 'can add active project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:notice].should include "Your project has been added to the group."
			end
			
			it 'can add funded project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'funded', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:notice].should include "Your project has been added to the group."
			end
			
			it 'can add nonfunded project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'nonfunded', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:notice].should include "Your project has been added to the group."
			end
			
			it 'can not add canceled project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'canceled', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:error].should include "You cannot add a canceld project."
			end
			
			it 'can not add group to a project twice' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
				@group.projects << @project
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:error].should include "Your project is already in this group."
			end
		end
		
		#
		#closed groups
		#
		
		context "adding projects to closed group" do
			before(:all) do
				@admin = FactoryGirl.create(:user2)
				@group = FactoryGirl.create(:group, :open => false, :admin_user_id => @admin.id)
			end
			
			after(:all) do
				@group.delete
				@admin.delete
			end
			
			it 'can add unconfirmed project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'unconfirmed', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:notice].should include "Your project has been submitted to the group admin for approval."
				assert !Approval.where(:project_id => @project.id, :group_id => @group.id, :approved => nil).first.nil?, "Missing approval."
			end
			
			it 'can add inactive project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'inactive', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:notice].should include "Your project has been submitted to the group admin for approval."
				assert !Approval.where(:project_id => @project.id, :group_id => @group.id, :approved => nil).first.nil?, "Missing approval."
			end
			it 'can add active project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:notice].should include "Your project has been submitted to the group admin for approval."
				assert !Approval.where(:project_id => @project.id, :group_id => @group.id, :approved => nil).first.nil?, "Missing approval."
			end
			
			it 'can add funded project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'funded', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:notice].should include "Your project has been submitted to the group admin for approval."
				assert !Approval.where(:project_id => @project.id, :group_id => @group.id, :approved => nil).first.nil?, "Missing approval."
			end
			
			it 'can add nonfunded project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'nonfunded', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:notice].should include "Your project has been submitted to the group admin for approval."
				assert !Approval.where(:project_id => @project.id, :group_id => @group.id, :approved => nil).first.nil?, "Missing approval."
			end
			
			it 'can not add canceled project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'canceled', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:error].should include "You cannot add a canceld project."
			end
			
			it 'can not add group to a project twice' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
				@group.projects << @project
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				flash[:error].should include "Your project is already in this group."
			end
		end

	end
end
