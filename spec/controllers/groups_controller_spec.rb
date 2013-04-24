require 'spec_helper'
require 'controller_helper'

describe GroupsController do
  include Devise::TestHelpers
  render_views

  # For stubbing abilities
  # See https://github.com/ryanb/cancan/wiki/Testing-Abilities
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub!(:current_ability).and_return(@ability)
  end

  describe 'GET index' do
    before { @ability.stub!(:can?).and_return(true) }
    before { get :index }

    it { should respond_with :success }
    it { should assign_to(:groups).with(Group.all) }
    it { should assign_to :user_groups }
    it { should assign_to :admin_groups }
    it { should render_template :index }
  end

  describe 'POST create' do
    context "when not signed in" do
      before { @ability.stub!(:can?).and_return(true) }

      it "does not allow group creation" do
        expect{ post 'create', group: attributes_for(:group) }.to_not change{ Group.count }
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to include "You need to sign in or sign up before continuing."
      end
    end

    context "when the user is signed in" do
      let(:user) { create :user }
      before(:each) { sign_in user }
      before { @ability.stub!(:can?).and_return(true) }

      it "allows group creation" do
        expect {post 'create', group: attributes_for(:group)}.to change {Group.count}.by 1
        expect(flash[:notice]).to include "Successfully created group."
      end
    end
  end

  describe 'POST new_add' do
    let(:group) { create :group }
    before { sign_in create :user }
    before { @ability.stub!(:can?).and_return(true) }
    before { post :new_add, id: group.id }

    it { should respond_with :success }
    it { should assign_to :group }
    it { should render_template :new_add }
  end

  describe 'POST submit_add' do

    context 'when the user is signed in' do
      let(:user) { create :user }
      before { sign_in user }

      before { @ability.stub!(:can?).with(:submit_add, group).and_return(true) }

      context "when the group is open and user is not the admin" do

        let(:group) { create :group, open: true }

        it 'allows adding of unconfirmed project to group' do
          project = create(:project, state: 'unconfirmed', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {group.projects.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

        it 'allows adding of inactive project to group' do
          project = create(:project, state: 'inactive', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {group.projects.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

        it 'allows adding of active project to group' do
          project = create(:project, state: 'active', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {group.projects.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

        it 'allows adding of funded project to group' do
          project = create(:project, state: 'funded', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {group.projects.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

        it 'allows adding of nonfunded project to group' do
          project = create(:project, state: 'nonfunded', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {group.projects.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

        it 'does not allow adding of cancelled project to group' do
          project = create(:project, state: 'cancelled', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to_not change {group.projects.count}

          expect(response).to redirect_to(group)
          expect(flash[:error]).to include "You cannot add a cancelled project."
        end

        it 'does not allow multiple additions of the same project to a group' do
          project = create(:project, state: 'active', user: user)
          group.projects << project
          expect {post 'submit_add', id: group.id, project_id: project.id}.to_not change {group.projects.count}

          expect(response).to redirect_to(group)
          expect(flash[:error]).to include "Your project is already in this group."
        end
      end

      context "when group is closed" do
        let(:admin) { create :user }
        let(:group) { create :group, open: false, admin_user: admin }

        it 'allows adding of unconfirmed project to group' do
          project = create(:project, state: 'unconfirmed', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {group.approvals.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
          expect(project.approvals.where(group_id: group.id, status: :pending).first).to_not be_nil
        end

        it 'allows adding of inactive project to group' do
          project = create(:project, state: 'inactive', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {group.approvals.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
          expect(project.approvals.where(group_id: group.id, status: :pending).first).to_not be_nil
        end

        it 'allows adding of active project to group' do
          project = create(:project, state: 'active', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {group.approvals.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
          expect(project.approvals.where(group_id: group.id, status: :pending).first).to_not be_nil
        end

        it 'allows adding of funded project to group' do
          project = create(:project, state: 'funded', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {group.approvals.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
          expect(project.approvals.where(group_id: group.id, status: :pending).first).to_not be_nil
        end

        it 'allows adding of nonfunded project to group' do
          project = create(:project, state: 'nonfunded', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {group.approvals.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
          expect(project.approvals.where(group_id: group.id, status: :pending).first).to_not be_nil
        end

        it 'does not allow adding of cancelled project to group' do
          project = create(:project, state: 'cancelled', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to_not change {group.approvals.count}

          expect(response).to redirect_to(group)
          expect(flash[:error]).to include "You cannot add a cancelled project."
        end

        it 'does not allow multiple additions of the same project to a group' do
          project = create(:project, state: 'active', user: user)
          group.projects << project
          expect {post 'submit_add', id: group.id, project_id: project.id}.to_not change {group.approvals.count}

          expect(response).to redirect_to(group)
          expect(flash[:error]).to include "Your project is already in this group."
        end
      end

    end
  end

  describe 'GET admin' do
    let(:approval) { create :approval }
    before { get :admin, id: approval.group.id, approval_id: approval.id }
    before { sign_in approval.group.admin_user }

    it { should redirect_to :root }
  end

  describe 'POST remove_project' do
    let(:group) { create :group }
    let(:project) { create :project }
    before { group.projects << project }
    before { @ability.stub!(:can?).and_return(true) }
    before { post :remove_project, id: group.id, project_id: project.id }

    it { should set_the_flash }
    it { should redirect_to group_path(group) }
  end

  describe 'POST destroy' do
    context 'when not signed in' do
      it "does not allow group deletion" do
        group = create :group
        expect {get 'destroy', id: group.id}.to_not change{Group.count}
        expect(flash[:alert]).to include "You are not authorized to access this page."
      end
    end
    context 'with permission' do
      let(:user) { create :user }
      before { sign_in user }
      let!(:group) { create :group, admin_user: user }
      before { @ability.stub!(:can?).with(:destroy, group).and_return(true) }

      it "allows group deletion" do
        expect {get 'destroy', id: group.id}.to change {Group.count}.by(-1)
        expect(response).to redirect_to(groups_path)
      end
    end

    context 'without permission' do
      let!(:group) { create :group }
      before { @ability.stub!(:can?).with(:destroy, group).and_return(false) }

      it "does not allow group deletion" do
        expect {get 'destroy', id: group.id}.to_not change {Group.count}
        expect(flash[:alert]).to include "You are not authorized to access this page."
      end
    end
  end

  describe 'GET edit' do
    context "when the user is signed in" do
      let(:user) { create :user }
      before(:each) { sign_in user }

      context 'with permission' do
        let!(:group) { create :group, admin_user: user }
        before { @ability.stub!(:can?).with(:edit, group).and_return(true) }

        it "allows group editing" do
          get 'edit', id: group.id
          expect(response).to be_success
        end
      end

      context 'without permission' do
        let!(:group) { create :group }
        before { @ability.stub!(:can?).with(:edit, group).and_return(false) }

        it "does not allow group editing" do
          get 'edit', id: group.id
          expect(flash[:alert]).to include "You are not authorized to access this page."
        end
      end
    end
  end

end
