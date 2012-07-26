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
				assert flash[:notice].include?("Successfully created group."), "Failed to create group."
			end
			
			it "not signed in user cannont create group" do
				post 'create', :group => FactoryGirl.attributes_for(:group)
				response.should redirect_to('/users/sign_in')
				assert flash[:alert].include?("You need to sign in or sign up before continuing."), "Should not be able to create group without signed in user."
			end
			
			it "admin can edit group" do
				sign_in @user
				@group = @group = FactoryGirl.create(:group, :open => true, :admin_user_id => @user.id)
				
				get 'edit', :id => @group.id
				response.should be_success
			end
			
			it "non admin can not edit group" do
				sign_in @user
				@group = @group = FactoryGirl.create(:group, :open => true, :admin_user_id => @user.id + 1)
				
				get 'edit', :id => @group.id
				assert flash[:alert].include?("You are not authorized to access this page."), "Only admin should be able to edit group."
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
				assert flash[:notice].include?("Your project has been added to the group."), "Failed to add unconfirmed project to a group."
			end
			
			it 'can add inactive project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'inactive', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:notice].include?("Your project has been added to the group."), "Failed to add inactive project to a group."
			end
			it 'can add active project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:notice].include?("Your project has been added to the group."), "Failed to add active project to a group."
			end
			
			it 'can add funded project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'funded', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:notice].include?("Your project has been added to the group."), "Failed to add funded project to a group."
			end
			
			it 'can add nonfunded project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'nonfunded', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:notice].include?("Your project has been added to the group."), "Failed to add nonfunded project to a group."
			end
			
			it 'can not add canceled project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'canceled', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:error].include?("You cannot add a canceld project to a group."), "Should not be able to add canceled project to a group."
			end
			
			it 'can not add group to a project twice' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
				@group.projects << @project
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:error].include?("Your project is already in this group."), "Should not be able to add project to group twice."
			end
		end
		
		#
		#closed groups
		#
		
		context "adding projects to closed group" do
			before(:all) do
				@group = FactoryGirl.create(:group, :open => false, :admin_user_id => @user.id)
			end
			
			after(:all) do
				@group.delete
			end
			
			it 'can add unconfirmed project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'unconfirmed', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:notice].include?("Your project has been submitted to the group owner for approval."), "Failed to add unconfirmed project to a group."
				assert !Approval.where(:project_id => @project.id, :group_id => @group.id, :approved => nil).first.nil?, "Missing approval."
			end
			
			it 'can add inactive project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'inactive', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:notice].include?("Your project has been submitted to the group owner for approval."), "Failed to add inactive project to a group."
				assert !Approval.where(:project_id => @project.id, :group_id => @group.id, :approved => nil).first.nil?, "Missing approval."
			end
			it 'can add active project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:notice].include?("Your project has been submitted to the group owner for approval."), "Failed to add active project to a group."
				assert !Approval.where(:project_id => @project.id, :group_id => @group.id, :approved => nil).first.nil?, "Missing approval."
			end
			
			it 'can add funded project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'funded', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:notice].include?("Your project has been submitted to the group owner for approval."), "Failed to add funded project to a group."
				assert !Approval.where(:project_id => @project.id, :group_id => @group.id, :approved => nil).first.nil?, "Missing approval."
			end
			
			it 'can add nonfunded project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'nonfunded', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:notice].include?("Your project has been submitted to the group owner for approval."), "Failed to add nonfunded project to a group."
				assert !Approval.where(:project_id => @project.id, :group_id => @group.id, :approved => nil).first.nil?, "Missing approval."
			end
			
			it 'can not add canceled project to group' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'canceled', :user_id => @user.id)
				
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:error].include?("You cannot add a canceld project to a group."), "Should not be able to add canceled project to a group."
			end
			
			it 'can not add group to a project twice' do
				sign_in @user
				@project = FactoryGirl.create(:project, :state => 'active', :user_id => @user.id)
				@group.projects << @project
				post 'submit_add', :id => @group.id, :project_id => @project.id
				
				response.should redirect_to(@group)
				assert flash[:error].include?("Your project is already in this group."), "Should not be able to add project to group twice."
			end
		end

	end
end
