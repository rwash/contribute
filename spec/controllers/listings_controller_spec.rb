require 'spec_helper'
require 'controller_helper'

describe ListingsController do
  include Devise::TestHelpers

  describe 'DELETE destroy' do
    # TODO create Listing factory
    let(:listing) { Listing.create(project_id: 2) }
    before { delete :destroy, id: listing.id }

    it { should redirect_to :root }
  end
end
