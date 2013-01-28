require 'spec_helper'
require 'controller_helper'

describe VideosController do
  include Devise::TestHelpers

  describe 'DELETE destroy' do
    context 'when video owner is signed in' do
      let(:video) { Factory :video }
      before { sign_in video.project.user }
      before { delete :destroy, id: video.id }

      it { should set_the_flash.to(/Successfully Deleted/) }
      it { should redirect_to project_path(video.project) }
    end

    context 'when user does not own video' do
      let(:video) { Factory :video }
      before { sign_in Factory :user }
      before { delete :destroy, id: video.id }

      it { should set_the_flash.to(/can not delete/) }
      it { should redirect_to :root }
    end

    context 'when video owner is not signed in' do
      let(:video) { Factory :video }
      before { delete :destroy, id: video.id }

      it { should set_the_flash.to(/sign in/) }
      it { should redirect_to new_user_session_path }
    end
  end
end
