require 'spec_helper'
require 'controller_helper'

describe ProjectListsController do
  include Devise::TestHelpers
  render_views

  # For stubbing abilities
  # See https://github.com/ryanb/cancan/wiki/Testing-Abilities
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub!(:current_ability).and_return(@ability)
  end

  describe 'POST sort' do
    # TODO we should have a test that at least touches this action
  end

  describe 'POST update' do
    # TODO we should have a test that at least touches this action
  end

  let(:user) { create :user }
  describe 'DELETE destroy' do
    context "when user is signed in" do
      before { sign_in user }

      context 'without permission' do
        let(:group) { create :group }
        before { @ability.stub(:can?).and_return(false) }

        it "does not allow group list deletion" do
          list = create(:project_list, listable_id: group.id, listable_type: "Group")
          expect { get :destroy, id: list.id }.to_not change {List.count}
          expect(response).to redirect_to(root_path)
        end

        it "does not allow user list deletion" do
          list = create(:project_list, listable: create(:user))
          expect { get :destroy, id: list.id }.to_not change {List.count}
          expect(response).to redirect_to(root_path)
        end
      end

      context "when user owns the list" do
        let(:group) { create :group, admin_user: user }
        before { @ability.stub(:can?).and_return(true) }

        it "allows group list destruction" do
          list = create(:project_list, listable_id: group.id, listable_type: "Group")
          expect { get :destroy, id: list.id }.to change {List.count}.by(-1)
          expect(response).to redirect_to(list.listable)
        end

        it "allows user list destruction" do
          list = create(:project_list, listable_id: user.id, listable_type: "User")
          expect { get :destroy, id: list.id }.to change {List.count}.by(-1)
          expect(response).to redirect_to(list.listable)
        end
      end
    end
  end

  describe 'GET edit' do
    context "when user is signed in" do
      let(:user) { create :user }
      before(:each) { sign_in user }

      context 'without permission' do
        before { @ability.stub!(:can?).and_return(false) }

        let(:group) { create :group }
        let(:user) { group.admin_user }

        it "does not allow group list editing" do
          list = create(:project_list, listable_id: group.id, listable_type: "Group")
          get :edit, id: list.id
          expect(response).to redirect_to(root_path)
        end

        it "does not allow user list editing" do
          list = create(:project_list, listable_id: user.id, listable_type: "User")
          get :edit, id: list.id
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe 'POST add_listing' do
    # TODO we should have a test that at least touches this action
  end

  describe 'GET show' do
    context "when user is not signed in" do
      context 'with permission' do
        before { @ability.stub(:can?).and_return(true) }

        it "displays users list" do
          list = create(:project_list, listable_id: create(:user).id, listable_type: "User")
          get :show, id: list.id
          expect(response).to be_success
          list.delete
        end

        it "displays groups list" do
          list = create(:project_list, listable_id: create(:group).id, listable_type: "Group")
          get :show, id: list.id
          expect(response).to be_success
          list.delete
        end
      end
    end
  end
end
