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

      it 'logs the user action' do
        post 'create', group: attributes_for(:group)
        group = Group.last
        should log_user_action user, :create, group
        UserAction.last.message.should match group.name
      end
    end
  end

  describe 'POST remove_project' do
    let(:group) { create :group }
    let(:project) { create :project }
    let(:user) { group.owner }

    before do
      group.projects << project
      @ability.stub!(:can?).and_return(true)
      sign_in user
      post :remove_project, id: group.id, project_id: project.id
    end

    it { should set_the_flash.to(/removed from group/) }
    it { should redirect_to group_path(group) }
    it { should log_user_action user, :remove_project, group }
    it 'logs the project id' do
      UserAction.last.message.should match 'project_id'
      UserAction.last.message.should match project.id.to_s
    end
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
      let!(:group) { create :group, owner: user }
      before { @ability.stub!(:can?).with(:destroy, group).and_return(true) }

      it "allows group deletion" do
        expect {get 'destroy', id: group.id}.to change {Group.count}.by(-1)
        expect(response).to redirect_to(groups_path)
      end

      it 'logs the user action' do
        get 'destroy', id: group.id
        action = UserAction.last
        action.user.should eq user
        action.event.should eq :destroy.to_s
        UserAction.last.subject_type.should eq 'Group'
        UserAction.last.subject_id.should eq group.id
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
        let!(:group) { create :group, owner: user }
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
