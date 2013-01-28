require 'spec_helper'
require 'controller_helper'

describe GroupsController do
  include Devise::TestHelpers

  describe 'POST create' do
    context "when not signed in" do
      it "does not allow group creation" do
        expect {post 'create', group: FactoryGirl.attributes_for(:group)}.to_not change{Group.count}
        expect(response).to redirect_to('/users/sign_in')
        expect(flash[:alert]).to include "You need to sign in or sign up before continuing."
      end
    end
    context "when the user is signed in" do
      let(:user) { Factory :user }
      before(:each) { sign_in user }

      it "allows group creation" do
        expect {post 'create', group: FactoryGirl.attributes_for(:group)}.to change {Group.count}.by 1
        expect(flash[:notice]).to include "Successfully created group."
      end
    end
  end

  describe 'POST destroy' do
    context 'when not signed in' do
      it "does not allow group deletion" do
        group = Factory :group
        expect {get 'destroy', id: group.id}.to_not change{Group.count}
        expect(flash[:alert]).to include "You are not authorized to access this page."
      end
    end
    context 'when group owner is signed in' do
      let(:user) { Factory :user }
      before(:each) { sign_in user }
      let!(:owned_group) { Factory :group, admin_user: user }
      it "allows group deletion" do
        expect {get 'destroy', id: owned_group.id}.to change {Group.count}.by(-1)
        expect(response).to redirect_to(groups_path)
      end
    end
    context "when the user does not own the group" do
      let!(:other_group) { Factory :group }

      it "does not allow group deletion" do
        expect {get 'destroy', id: other_group.id}.to_not change {Group.count}
        expect(flash[:alert]).to include "You are not authorized to access this page."
      end
    end
  end

  describe 'GET edit' do
    context "when the user is signed in" do
      let(:user) { Factory :user }
      before(:each) { sign_in user }

      context "when the user owns the group" do
        let!(:owned_group) { Factory :group, admin_user: user }

        it "allows group editing" do
          get 'edit', id: owned_group.id
          expect(response).to be_success
        end
      end
      context "when the user does not own the group" do
        let!(:other_group) { Factory :group }

        it "does not allow group editing" do
          get 'edit', id: other_group.id
          expect(flash[:alert]).to include "You are not authorized to access this page."
        end
      end
    end
  end

  describe 'POST submit_add' do
    context 'when the user is signed in' do
      let(:user) { Factory :user }
      before(:each) { sign_in user }
      context "when the group is open and user is not the admin" do
        let(:group) { Factory :group, open: true }

        it 'allows adding of unconfirmed project to group' do
          project = Factory(:project, state: 'unconfirmed', user: user)

          expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

          expect(response).to redirect_to(group)
          expect(flash[:notice]).to include "Your project has been added to the group."
        end

      it 'allows adding of inactive project to group' do
        project = Factory(:project, state: 'inactive', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:notice]).to include "Your project has been added to the group."
      end

      it 'allows adding of active project to group' do
        project = Factory(:project, state: 'active', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:notice]).to include "Your project has been added to the group."
      end

      it 'allows adding of funded project to group' do
        project = Factory(:project, state: 'funded', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:notice]).to include "Your project has been added to the group."
      end

      it 'allows adding of nonfunded project to group' do
        project = Factory(:project, state: 'nonfunded', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:notice]).to include "Your project has been added to the group."
      end

      it 'does not allow adding of cancelled project to group' do
        project = Factory(:project, state: 'cancelled', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:error]).to include "You cannot add a cancelled project."
      end

      it 'does not allow multiple additions of the same project to a group' do
        project = Factory(:project, state: 'active', user: user)
        group.projects << project
        expect {post 'submit_add', id: group.id, project_id: project.id}.to_not change {group.projects.count}

        expect(response).to redirect_to(group)
        expect(flash[:error]).to include "Your project is already in this group."
      end
      end

    context "when group is closed" do
      let(:admin) { Factory :user }
      let(:group) { Factory :group, open: false, admin_user: admin }

      it 'allows adding of unconfirmed project to group' do
        project = Factory(:project, state: 'unconfirmed', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
        expect(project.approvals.where(group_id: group.id, approved: nil).first).to_not be_nil
      end

      it 'allows adding of inactive project to group' do
        project = Factory(:project, state: 'inactive', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
        expect(project.approvals.where(group_id: group.id, approved: nil).first).to_not be_nil
      end

      it 'allows adding of active project to group' do
        project = Factory(:project, state: 'active', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
        expect(project.approvals.where(group_id: group.id, approved: nil).first).to_not be_nil
      end

      it 'allows adding of funded project to group' do
        project = Factory(:project, state: 'funded', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
        expect(project.approvals.where(group_id: group.id, approved: nil).first).to_not be_nil
      end

      it 'allows adding of nonfunded project to group' do
        project = Factory(:project, state: 'nonfunded', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:notice]).to include "Your project has been submitted to the group admin for approval."
        expect(project.approvals.where(group_id: group.id, approved: nil).first).to_not be_nil
      end

      it 'does not allow adding of cancelled project to group' do
        project = Factory(:project, state: 'cancelled', user: user)

        expect {post 'submit_add', id: group.id, project_id: project.id}.to change {Group.count}.by 1

        expect(response).to redirect_to(group)
        expect(flash[:error]).to include "You cannot add a cancelled project."
      end

      it 'does not allow multiple additions of the same project to a group' do
        project = Factory(:project, state: 'active', user: user)
        group.projects << project
        expect {post 'submit_add', id: group.id, project_id: project.id}.to_not change {group.projects.count}

        expect(response).to redirect_to(group)
        expect(flash[:error]).to include "Your project is already in this group."
      end
    end

    end
  end
end
