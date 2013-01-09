require 'spec_helper'
require 'controller_helper'

describe ApprovalsController do
  include Devise::TestHelpers

  describe "functional tests:" do
    render_views

    before(:all) do
      @user = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)

      @group = FactoryGirl.create(:group, :admin_user_id => @user.id, :open => false)
      @project = FactoryGirl.create(:project, :user_id => @user2.id)
      @approval = FactoryGirl.create(:approval, :group_id => @group.id, :project_id => @project.id)
    end

    after(:all) do
      @user.delete
      @user2.delete
      @group.delete
      @project.delete
      @approval.delete
    end

    context "admin can" do
      it "admin can approve approval" do
        sign_in @user

        get 'approve', :group_id => @group.id, :id => @approval.id
        response.should redirect_to(group_admin_path(@group))
      end

      it "admin can reject approval" do
        sign_in @user

        get 'reject', :group_id => @group.id, :id => @approval.id, :reason => "I dont know"
        response.should redirect_to(group_admin_path(@group))
      end
    end

    context "admin cannot" do
      before(:all) do
        @group.admin_user_id += 1
        @group.save!
      end

      it "non admin cannot approve" do
        sign_in @user

        get 'approve', :group_id => @group.id, :id => @approval.id
        response.should redirect_to(group_admin_path(@group))
      end

      it "non admin cannot reject" do
        sign_in @user

        get 'reject', :group_id => @group.id, :id => @approval.id, :reason => "I dont know"
        response.should redirect_to(group_admin_path(@group))
      end
    end
  end
end
