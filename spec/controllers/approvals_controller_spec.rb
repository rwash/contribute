require 'spec_helper'

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

  describe 'GET index' do
    let(:approval) { create :approval }
    before { get :index, group_id: approval.group.id, approval_id: approval.id }
    before { sign_in approval.group.owner }

    it { should redirect_to :root }
  end

  describe 'GET new' do
    let(:group) { create :group }
    let(:user) { create :user }
    before { sign_in user }
    before { @ability.stub!(:can?).and_return(true) }
    before { get :new, group_id: group.id }

    it { should respond_with :success }
    it { should assign_to :group }
    it { should render_template :new }
  end

  describe 'POST create' do

    context 'when the user is signed in' do
      let(:user) { create :user }
      before { sign_in user }

      before { @ability.stub!(:can?).and_return(true) }

      context "when the group is open and user is not the admin" do

        let(:group) { create :group, open: true }

        it 'logs the user action' do
          project = create(:project, state: 'unconfirmed', owner: user)
          post :create, group_id: group.id, project_id: project.id
          should log_user_action user, :create, Approval.last
        end

        it 'allows adding of unconfirmed project to group' do
          project = create(:project, state: 'unconfirmed', owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to change {group.projects.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

        it 'allows adding of inactive project to group' do
          project = create(:project, state: 'inactive', owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to change {group.projects.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

        it 'allows adding of active project to group' do
          project = create(:active_project, owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to change {group.projects.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

        it 'allows adding of funded project to group' do
          project = create(:project, state: 'funded', owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to change {group.projects.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

        it 'allows adding of nonfunded project to group' do
          project = create(:project, state: 'nonfunded', owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to change {group.projects.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

        it 'does not allow adding of cancelled project to group' do
          project = create(:project, state: 'cancelled', owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to_not change {group.projects.count}

          expect(response).to redirect_to(group)
          expect(flash[:error]).to include "You cannot add a cancelled project."
        end

        it 'does not allow multiple additions of the same project to a group' do
          project = create(:active_project, owner: user)
          group.projects << project
          expect {post :create, group_id: group.id, project_id: project.id}.to_not change {group.projects.count}

          expect(response).to redirect_to(group)
          expect(flash[:error]).to include "Your project is already in this group."
        end
      end

      context "when group is closed" do
        let(:admin) { create :user }
        let(:group) { create :group, open: false, owner: admin }

        it 'allows adding of unconfirmed project to group' do
          project = create(:project, state: 'unconfirmed', owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to change {group.approvals.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
          expect(project.approvals.where(group_id: group.id, status: :pending).first).to_not be_nil
        end

        it 'allows adding of inactive project to group' do
          project = create(:project, state: 'inactive', owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to change {group.approvals.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
          expect(project.approvals.where(group_id: group.id, status: :pending).first).to_not be_nil
        end

        it 'allows adding of active project to group' do
          project = create(:active_project, owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to change {group.approvals.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
          expect(project.approvals.where(group_id: group.id, status: :pending).first).to_not be_nil
        end

        it 'allows adding of funded project to group' do
          project = create(:project, state: 'funded', owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to change {group.approvals.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
          expect(project.approvals.where(group_id: group.id, status: :pending).first).to_not be_nil
        end

        it 'allows adding of nonfunded project to group' do
          project = create(:project, state: 'nonfunded', owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to change {group.approvals.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
          expect(project.approvals.where(group_id: group.id, status: :pending).first).to_not be_nil
        end

        it 'does not allow adding of cancelled project to group' do
          project = create(:project, state: 'cancelled', owner: user)

          expect {post :create, group_id: group.id, project_id: project.id}.to_not change {group.approvals.count}

          expect(response).to redirect_to(group)
          expect(flash[:error]).to include "You cannot add a cancelled project."
        end

        it 'does not allow multiple additions of the same project to a group' do
          project = create(:active_project, owner: user)
          group.projects << project
          expect {post :create, group_id: group.id, project_id: project.id}.to_not change {group.approvals.count}

          expect(response).to redirect_to(group)
          expect(flash[:error]).to include "Your project is already in this group."
        end
      end

    end
  end


  describe 'POST approve' do
    context 'with permission' do
      before { @ability.stub!(:can?).with(:approve, approval).and_return(true) }
      before { post 'approve', group_id: group.id, id: approval.id }

      it "updates approval status" do
        expect(approval.reload.status).to eq :approved
      end

      it { should redirect_to group_approvals_path(group) }
      it { should_not set_the_flash }
      it { should log_user_action user, :approve, approval }
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

      it { should redirect_to group_approvals_path(group) }
      it { should_not set_the_flash }
      it { should log_user_action user, :reject, approval }
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
