require 'spec_helper'
require 'controller_helper'

describe ApprovalsController do
  include Devise::TestHelpers

  let(:user) { Factory :user }
  before(:each) { sign_in user }

  context "when signed in as an admin" do
    let(:group) { Factory :group, admin_user: user, open: false }
    let(:approval) { Factory :approval, group: group }

    it "allows approvals", :broken do
      post 'approve', :group_id => group.id, :id => approval.id
      response.should redirect_to(group_admin_path(group))
    end

    it "allows rejections", :broken do
      post 'reject', :group_id => group.id, :id => approval.id, :reason => "I dont know"
      response.should redirect_to(group_admin_path(group))
    end
  end

  context "when not signed in as an admin" do
    let(:group) { Factory :group, open: false }
    let(:approval) { Factory :approval, group: group }

    it "does not allow approvals", :broken do
      post 'approve', :group_id => group.id, :id => approval.id
      response.should redirect_to(group_admin_path(group))
    end

    it "does not allow rejections", :broken do
      post 'reject', :group_id => group.id, :id => approval.id, :reason => "I dont know"
      response.should redirect_to(group_admin_path(group))
    end
  end
end
