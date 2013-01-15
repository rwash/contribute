require 'spec_helper'
require 'controller_helper'

describe UpdatesController do
  include Devise::TestHelpers

  context "create action" do
    let(:project) { Factory :project, state: :active }
    let(:user) { project.user }

    context "user is signed in" do
      before(:each) { sign_in user }

      it 'can create an update' do
        expect {post 'create', :project_id => project.id, :update => FactoryGirl.attributes_for(:update)}.to change{ Update.count }.by 1
        response.should redirect_to(project_path(project))
        flash[:notice].should == "Update saved succesfully."
      end

      it 'update should start with email_sent = false' do
        expect {post 'create', :project_id => project.id, :update => FactoryGirl.attributes_for(:update)}.to change {Update.count}.by 1
        response.should redirect_to(project_path(project))
        Update.last.email_sent.should == false
      end

      it 'fails for incomplete update' do
        expect{ post 'create', :project_id => project.id }.to_not change {Update.count}
        response.should redirect_to(project_path(project))
        flash[:error].should include "Update failed to save."
      end
    end

    context "user is not signed in" do
      it 'does not allow creation' do
        expect {post 'create', :project_id => project.id, :update => FactoryGirl.attributes_for(:update)}.to_not change {Update.count}
        response.should redirect_to(project_path(project))
        flash[:error].should include "You cannot update this project."
      end

      it 'fails for user who is not project owner'
    end
  end
end
