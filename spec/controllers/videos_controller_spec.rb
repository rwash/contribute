require 'spec_helper'
require 'controller_helper'

describe VideosController do
  include Devise::TestHelpers

  # For stubbing CanCan Abilities
  # See https://github.com/ryanb/cancan/wiki/Testing-Abilities
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub!(:current_ability).and_return(@ability)
  end

  let(:user) { Factory :user }

  describe 'DELETE destroy' do
    context 'while signed in' do
      before { sign_in user }

      context 'with permission' do
        before { @ability.stub!(:can?).with(:destroy, video).and_return(true) }
        let(:video) { Factory :video }

        before { delete :destroy, id: video.id }

        it { should set_the_flash.to(/Successfully Deleted/) }
        it { should redirect_to project_path(video.project) }
      end

      context 'when user does not own video' do
        before { @ability.stub!(:can?).with(:destroy, video).and_return(false) }
        let(:video) { Factory :video }
        before { delete :destroy, id: video.id }

        it { should set_the_flash.to(/not authorized/) }
        it { should redirect_to :root }
      end
    end

    context 'while not signed in' do
      let(:video) { Factory :video }
      before { delete :destroy, id: video.id }

      it { should set_the_flash.to(/sign in/) }
      it { should redirect_to new_user_session_path }
    end
  end
end
