require 'spec_helper'
require 'controller_helper'

describe GroupsController do
  include Devise::TestHelpers

  let(:user) { Factory :user }

	describe "functional tests:" do
		render_views

    let(:owned_group) { Factory :group, admin_user: user }
    let(:other_group) { Factory :group }
		
		context "creating groups" do
			it "signed in user can create group" do
				sign_in user
				post 'create', :group => FactoryGirl.attributes_for(:group)
				flash[:notice].should include "Successfully created group."
			end
			
			it "not signed in user cannont create group" do
				post 'create', :group => FactoryGirl.attributes_for(:group)
				response.should redirect_to('/users/sign_in')
				flash[:alert].should include "You need to sign in or sign up before continuing."
			end
			
			it "admin can edit group" do
				sign_in user
				
				get 'edit', :id => owned_group.id
				response.should be_success
			end
			
			it "non admin can not edit group" do
				sign_in user
				
				get 'edit', :id => other_group.id
				flash[:alert].should include "You are not authorized to access this page."
			end
		end
		
		context "destroy groups" do
			it "not signed in user cannot delete group" do
				get 'destroy', :id => other_group.id
				flash[:alert].should include "You are not authorized to access this page."
			end
			it "signed in user cannot delete group it doesnt own" do
				sign_in user
				
				get 'destroy', id: other_group.id
				flash[:alert].should include "You are not authorized to access this page."
			end
			it "signed in user can delete groups it is admin of" do
				sign_in user
				
				get 'destroy', :id => owned_group.id
				response.should redirect_to(groups_path)
			end
		end
		
		#
		#open groups
		#
		
		context "adding projects to open group" do
			
			it 'can add unconfirmed project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'unconfirmed', :user_id => user.id)
				
				post 'submit_add', :id => owned_group.id, :project_id => project.id
				
				response.should redirect_to(owned_group)
				flash[:notice].should include "Your project has been added to the group."
			end
			
			it 'can add inactive project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'inactive', :user_id => user.id)
				
				post 'submit_add', :id => owned_group.id, :project_id => project.id
				
				response.should redirect_to(owned_group)
				flash[:notice].should include "Your project has been added to the group."
			end
			it 'can add active project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'active', :user_id => user.id)
				
				post 'submit_add', :id => owned_group.id, :project_id => project.id
				
				response.should redirect_to(owned_group)
				flash[:notice].should include "Your project has been added to the group."
			end
			
			it 'can add funded project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'funded', :user_id => user.id)
				
				post 'submit_add', :id => owned_group.id, :project_id => project.id
				
				response.should redirect_to(owned_group)
				flash[:notice].should include "Your project has been added to the group."
			end
			
			it 'can add nonfunded project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'nonfunded', :user_id => user.id)
				
				post 'submit_add', :id => owned_group.id, :project_id => project.id
				
				response.should redirect_to(owned_group)
				flash[:notice].should include "Your project has been added to the group."
			end
			
			it 'can not add cancelled project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'cancelled', :user_id => user.id)
				
				post 'submit_add', :id => owned_group.id, :project_id => project.id
				
				response.should redirect_to(owned_group)
				flash[:error].should include "You cannot add a cancelled project."
			end
			
			it 'can not add project to a group twice' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'active', :user_id => user.id)
				owned_group.projects << project
				post 'submit_add', :id => owned_group.id, :project_id => project.id
				
				response.should redirect_to(owned_group)
				flash[:error].should include "Your project is already in this group."
			end
		end
		
		#
		#closed groups
		#
		
		context "adding projects to closed group" do
      let(:admin) { Factory :user }
      let(:group) { Factory :group, open: false, admin_user: admin }
			
			it 'can add unconfirmed project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'unconfirmed', :user_id => user.id)
				
				post 'submit_add', :id => group.id, :project_id => project.id
				
				response.should redirect_to(group)
				flash[:notice].should include "Your project has been submitted to the group admin for approval."
				Approval.where(:project_id => project.id, :group_id => group.id, :approved => nil).first.should_not be_nil
			end
			
			it 'can add inactive project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'inactive', :user_id => user.id)
				
				post 'submit_add', :id => group.id, :project_id => project.id
				
				response.should redirect_to(group)
				flash[:notice].should include "Your project has been submitted to the group admin for approval."
				Approval.where(:project_id => project.id, :group_id => group.id, :approved => nil).first.should_not be_nil
			end
			it 'can add active project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'active', :user_id => user.id)
				
				post 'submit_add', :id => group.id, :project_id => project.id
				
				response.should redirect_to(group)
				flash[:notice].should include "Your project has been submitted to the group admin for approval."
				Approval.where(:project_id => project.id, :group_id => group.id, :approved => nil).first.should_not be_nil
			end
			
			it 'can add funded project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'funded', :user_id => user.id)
				
				post 'submit_add', :id => group.id, :project_id => project.id
				
				response.should redirect_to(group)
				flash[:notice].should include "Your project has been submitted to the group admin for approval."
				Approval.where(:project_id => project.id, :group_id => group.id, :approved => nil).first.should_not be_nil
			end
			
			it 'can add nonfunded project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'nonfunded', :user_id => user.id)
				
				post 'submit_add', :id => group.id, :project_id => project.id
				
				response.should redirect_to(group)
				flash[:notice].should include "Your project has been submitted to the group admin for approval."
				Approval.where(:project_id => project.id, :group_id => group.id, :approved => nil).first.should_not be_nil
			end
			
			it 'can not add cancelled project to group' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'cancelled', :user_id => user.id)
				
				post 'submit_add', :id => group.id, :project_id => project.id
				
				response.should redirect_to(group)
				flash[:error].should include "You cannot add a cancelled project."
			end
			
			it 'can not add group to a project twice' do
				sign_in user
				project = FactoryGirl.create(:project, :state => 'active', :user_id => user.id)
				group.projects << project
				post 'submit_add', :id => group.id, :project_id => project.id
				
				response.should redirect_to(group)
				flash[:error].should include "Your project is already in this group."
			end
		end

	end
end
