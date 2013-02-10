require 'spec_helper'
require 'controller_helper'

describe UpdatesController do
  include Devise::TestHelpers

  # For stubbing abilities
  # See https://github.com/ryanb/cancan/wiki/Testing-Abilities
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub!(:current_ability).and_return(@ability)
  end

  let(:user) { create :user }

  describe 'POST create' do
    let(:project) { create :project, state: :active }

    context "when user is signed in" do
      before { sign_in user }
      before { reset_email }

      context 'with permission' do
        before { @ability.stub!(:can?).and_return(true) }

        context 'for a valid update' do
          let(:project) { create :project, state: :unconfirmed }
          before { post :create, project_id: project.id, update: attributes_for(:update) }

          it 'creates an update' do
            expect{ post 'create', project_id: project.id, update: attributes_for(:update)}.to change{ Update.count }.by 1
          end

          it { should redirect_to project_path(project) }
          it { should set_the_flash.to "Update saved successfully." }

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
      end

      context 'without permission' do
        before { @ability.stub!(:can?).and_return(false) }
        before { post 'create', project_id: project.id, update: attributes_for(:update) }

        it 'does not create an update' do
          expect {post 'create', project_id: project.id, update: attributes_for(:update)}.to_not change{ Update.count }
        end

        it { should redirect_to :root }
        it { should set_the_flash.to(/cannot update/) }
      end
    end

    context "when user is not signed in" do
      before { post :create, project_id: project.id, update: attributes_for(:update) }

      it { should redirect_to new_user_session_path }
      it { should set_the_flash.to(/sign in/) }

      it 'does not create an update' do
        expect{ post 'create', project_id: project.id, update: attributes_for(:update)}.to_not change { Update.count }
      end
    end
  end
end
