require 'spec_helper'
require 'controller_helper'

describe ApprovalsController do
  include Devise::TestHelpers
  render_views

  let(:user) { create :user }
  before { sign_in user }

  let(:group) { create :group, open: false }
  let(:approval) { create :approval, group: group }

  # For stubbing abilities
  # See https://github.com/ryanb/cancan/wiki/Testing-Abilities
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub!(:current_ability).and_return(@ability)
  end

  describe 'POST approve' do
    context 'with permission' do
      before { @ability.stub!(:can?).with(:approve, approval).and_return(true) }
      before { post 'approve', group_id: group.id, id: approval.id }

      it "updates approval status" do
        expect(approval.reload.status).to eq :approved
      end

      it { should redirect_to group_admin_path(group) }
      it { should_not set_the_flash }
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:approve, approval).and_return(false) }
      before { post 'approve', group_id: group.id, id: approval.id }

      it "does not update approval status", :broken do
        expect(approval.reload.status).to eq :pending
      end

      it { should redirect_to root_url }
      it { should set_the_flash }
    end
  end

  describe 'POST reject' do
    context 'with permisison' do
      before { @ability.stub!(:can?).with(:reject, approval).and_return(true) }
      before { post 'reject', group_id: group.id, id: approval.id, reason: "I dont know" }

      it "updates approval status" do
        expect(approval.reload.status).to eq :rejected
      end

      it { should redirect_to group_admin_path(group) }
      it { should_not set_the_flash }
    end

    context 'without permission' do
      before { @ability.stub!(:can?).with(:reject, approval).and_return(false) }
      before { post 'reject', group_id: group.id, id: approval.id, reason: "I dont know" }

      it "does not update approval status", :broken do
        expect { post 'reject', group_id: group.id, id: approval.id }.to_not change {approval.reload.status}
      end

      it { should redirect_to root_url }
      it { should set_the_flash }
    end
  end
end
