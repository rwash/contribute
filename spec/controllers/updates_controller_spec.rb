require 'spec_helper'
require 'controller_helper'

describe UpdatesController do
  include Devise::TestHelpers

  describe 'POST create' do
    let(:project) { Factory :project, state: :active }
    let(:user) { project.user }

    context "when user is signed in" do
      before { sign_in user }
      before { reset_email }

      context 'for a valid update' do
        before { post :create, project_id: project.id, update: Factory.attributes_for(:update) }

        it 'creates an update' do
          expect {post 'create', project_id: project.id, update: FactoryGirl.attributes_for(:update)}.to change{ Update.count }.by 1
        end

        it { should redirect_to project_path(project) }
        # TODO fix typo in 'successfully'
        it { should set_the_flash.to "Update saved succesfully." }

        it 'does not immediately send an email' do
          expect(Update.last.email_sent).to eq false
          expect(all_emails).to be_empty
        end
      end

      context 'for an incomplete update' do
        before { post :create, project_id: project.id }

        it 'does not create an update' do
          expect{ post 'create', project_id: project.id }.to_not change {Update.count}
        end

        it { should redirect_to project_path(project) }
        it { should set_the_flash.to(/Update failed to save/) }
      end

      context 'when user does not own project' do
        let(:user) { Factory :user }
        before { sign_in user }
        before { post 'create', project_id: project.id, update: FactoryGirl.attributes_for(:update) }

        it 'does not create an update' do
          expect {post 'create', project_id: project.id, update: FactoryGirl.attributes_for(:update)}.to_not change{ Update.count }
        end

        it { should redirect_to project_path(project) }
        it { should set_the_flash.to(/cannot update/) }
      end
    end

    context "when user is not signed in" do
      before { post :create, project_id: project.id, update: Factory.attributes_for(:update) }

      it { should redirect_to project_path(project) }
      it { should set_the_flash.to(/You cannot update this project\./) }

      it 'does not create an update' do
        expect {post 'create', project_id: project.id, update: FactoryGirl.attributes_for(:update)}.to_not change {Update.count}
      end
    end
  end
end
