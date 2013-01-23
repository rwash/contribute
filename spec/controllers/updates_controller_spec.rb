require 'spec_helper'
require 'controller_helper'

describe UpdatesController do
  include Devise::TestHelpers

  context "create action" do
    let(:project) { Factory :project, state: :active }
    let(:user) { project.user }

    context "user is signed in" do
      before(:each) { sign_in user }

      it 'allows update creation' do
        expect {post 'create', :project_id => project.id, :update => FactoryGirl.attributes_for(:update)}.to change{ Update.count }.by 1
        expect(response).to redirect_to(project_path(project))
        expect(flash[:notice]).to eq "Update saved succesfully."
      end

      it 'does not immediately send an email' do
        reset_email
        expect {
          post 'create', :project_id => project.id, :update => FactoryGirl.attributes_for(:update)
        }.to change {Update.count}.by 1
        expect(response).to redirect_to(project_path(project))
        expect(Update.last.email_sent).to eq false
        expect(all_emails).to be_empty
      end

      it 'fails for incomplete update' do
        expect{ post 'create', :project_id => project.id }.to_not change {Update.count}
        expect(response).to redirect_to(project_path(project))
        expect(flash[:error]).to include "Update failed to save."
      end

      it 'fails for user who is not project owner' do
        sign_in Factory :user
        expect {post 'create', :project_id => project.id, :update => FactoryGirl.attributes_for(:update)}.to_not change{ Update.count }
        expect(response).to redirect_to(project_path(project))
        expect(flash[:error]).to include "cannot update"
      end
    end

    context "user is not signed in" do
      it 'does not allow creation' do
        expect {post 'create', :project_id => project.id, :update => FactoryGirl.attributes_for(:update)}.to_not change {Update.count}
        expect(response).to redirect_to(project_path(project))
        expect(flash[:error]).to include "You cannot update this project."
      end
    end
  end
end
