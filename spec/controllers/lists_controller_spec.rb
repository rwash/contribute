require 'spec_helper'
require 'controller_helper'

describe ListsController do
  include Devise::TestHelpers
  
	describe "functional tests:" do
		render_views

    let(:user) { Factory :user }
    let(:user2) { Factory :user }
		let(:group) { Factory :group, :admin_user => user }
		let(:group2) { Factory :group, :admin_user => user2 }
	
		context "creating lists" do
			it "anyone can view users list" do
				list = FactoryGirl.create(:list, :listable_id => user.id, :listable_type => "User")
				get :show, :id => list.id
				response.should be_success
				list.delete
			end
			
			it "anyone can view groups list" do
				list = FactoryGirl.create(:list, :listable_id => group.id, :listable_type => "Group")
				get :show, :id => list.id
				response.should be_success
				list.delete
			end
			
			it "user cannot destroy list it doesnt own" do
				sign_in user
				
				list = FactoryGirl.create(:list, :listable_id => group2.id, :listable_type => "Group")
				get :destroy, :id => list.id
				response.should redirect_to(root_path)
			end
			
			it "user cannot destroy list it doesnt own (user)" do
				sign_in user
				
				list = FactoryGirl.create(:list, :listable_id => user2.id, :listable_type => "User")
				get :destroy, :id => list.id
				response.should redirect_to(root_path)
			end
			
			it "user can destroy list it does own" do
				sign_in user
				
				list = FactoryGirl.create(:list, :listable_id => group.id, :listable_type => "Group")
				get :destroy, :id => list.id
				response.should redirect_to(list.listable)
			end
			
			it "user can destroy list it does own (user)" do
				sign_in user
				
				list = FactoryGirl.create(:list, :listable_id => user.id, :listable_type => "User")
				get :destroy, :id => list.id
				response.should redirect_to(list.listable)
			end
		
			it "user cannot edit list it doesnt own" do
				sign_in user
				
				list = FactoryGirl.create(:list, :listable_id => group2.id, :listable_type => "Group")
				get :edit, :id => list.id
				response.should redirect_to(root_path)
			end
			
			it "user cannot edit list it doesnt own (user)" do
				sign_in user
				
				list = FactoryGirl.create(:list, :listable_id => user2.id, :listable_type => "User")
				get :edit, :id => list.id
				response.should redirect_to(root_path)
			end
		end
	end
end
