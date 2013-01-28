require 'spec_helper'
require 'controller_helper'

describe VideosController do
  include Devise::TestHelpers

  describe 'DELETE destroy' do
    let(:video) { Factory :video }

    before { sign_in video.project.user }
    before { delete :destroy, id: video.id }

    it { should set_the_flash.to(/Successfully Deleted/) }
    it { should redirect_to project_path(video.project) }
  end
end
