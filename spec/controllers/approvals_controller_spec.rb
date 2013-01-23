require 'spec_helper'
require 'controller_helper'

describe ApprovalsController do
  include Devise::TestHelpers

  let(:user) { Factory :user }
  before { sign_in user }

  context "when signed in as an admin" do
    let(:group) { Factory :group, admin_user: user, open: false }
    let(:approval) { Factory :approval, group: group }

    describe 'POST approve' do
      before do
        post 'approve', group_id: group.id, id: approval.id
      end

      it "updates approval status" do
        expect(approval.reload.approved).to be_true
      end

      it { should redirect_to group_admin_path(group) }
      it { should_not set_the_flash }
    end

    describe 'POST reject' do
      before do
        post 'reject', group_id: group.id, id: approval.id, reason: "I dont know"
      end

      it "updates approval status" do
        expect(approval.reload.approved).to be_false
      end

      it { should redirect_to group_admin_path(group) }
      it { should_not set_the_flash }
    end
  end

  context "when not signed in as admin" do
    let(:group) { Factory :group, open: false }
    let(:approval) { Factory :approval, group: group }

    describe 'POST approve' do
      before { post 'approve', group_id: group.id, id: approval.id }

      it "does not update approved attribute", :broken do
        expect(approval.reload.approved).to be_nil
      end

      it { should redirect_to root_url }
      it { should set_the_flash }
    end

    describe 'POST reject' do
      before { post 'reject', group_id: group.id, id: approval.id }

      it "does not allow approvals", :broken do
        expect { post 'reject', group_id: group.id, id: approval.id }.to_not change {approval.reload.approved}
      end

      it { should redirect_to root_url }
      it { should set_the_flash }
    end
  end
end
