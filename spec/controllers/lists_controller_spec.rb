require 'spec_helper'
require 'controller_helper'

describe ListsController do
  include Devise::TestHelpers

  context "when user is not signed in" do
    it "displays users list" do
      list = FactoryGirl.create(:list, :listable_id => Factory(:user).id, :listable_type => "User")
      get :show, :id => list.id
      expect(response).to be_success
      list.delete
    end

    it "displays groups list" do
      list = FactoryGirl.create(:list, :listable_id => Factory(:group).id, :listable_type => "Group")
      get :show, :id => list.id
      expect(response).to be_success
      list.delete
    end
  end

  context "when user is signed in" do
    let(:current_user) { Factory :user }
    before(:each) { sign_in current_user }

    context "when user does not own the list" do
      let(:group) { Factory :group }
      let(:user) { group.admin_user }

      it "does not allow group list deletion" do
        list = FactoryGirl.create(:list, :listable_id => group.id, :listable_type => "Group")
        expect { get :destroy, :id => list.id }.to_not change {List.count}
        expect(response).to redirect_to(root_path)
      end

      it "does not allow user list deletion" do
        list = FactoryGirl.create(:list, :listable_id => user.id, :listable_type => "User")
        expect { get :destroy, :id => list.id }.to_not change {List.count}
        expect(response).to redirect_to(root_path)
      end

      it "does not allow group list editing" do
        list = FactoryGirl.create(:list, :listable_id => group.id, :listable_type => "Group")
        get :edit, :id => list.id
        expect(response).to redirect_to(root_path)
      end

      it "does not allow user list editing" do
        list = FactoryGirl.create(:list, :listable_id => user.id, :listable_type => "User")
        get :edit, :id => list.id
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user owns the list" do
      let(:user) { current_user }
      let(:group) { Factory :group, :admin_user => user }

      it "allows group list destruction" do
        list = FactoryGirl.create(:list, :listable_id => group.id, :listable_type => "Group")
        expect { get :destroy, :id => list.id }.to change {List.count}.by(-1)
        expect(response).to redirect_to(list.listable)
      end

      it "allows user list destruction" do
        list = FactoryGirl.create(:list, :listable_id => user.id, :listable_type => "User")
        expect { get :destroy, :id => list.id }.to change {List.count}.by(-1)
        expect(response).to redirect_to(list.listable)
      end
    end
  end
end
