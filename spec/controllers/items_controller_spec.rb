require 'spec_helper'
require 'controller_helper'

describe ItemsController do
  include Devise::TestHelpers

  describe 'DELETE destroy' do
    let(:item) { Item.create(itemable_id: 2, itemable_type:'Project') }
    before { delete :destroy, id: item.id }

    it { should redirect_to :root }
  end
end
