require 'spec_helper'
require 'controller_helper'

describe ListingsController do
  include Devise::TestHelpers

  # For stubbing abilities
  # See https://github.com/ryanb/cancan/wiki/Testing-Abilities
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub!(:current_ability).and_return(@ability)
  end

  describe 'DELETE destroy' do
    context 'without permission' do
      before { @ability.stub!(:can?).and_return(false) }
      before { delete :destroy, id: create(:project_listing) }

      it 'does not destroy the record' do
        listing = create(:project_listing)
        expect { delete :destroy, id: listing }.to_not change { ProjectListing.count }
      end
      it { should redirect_to :root }
      it { should set_the_flash }
    end

    context 'with permission' do
      before { @ability.stub!(:can?).and_return(true) }
      before { delete :destroy, id: create(:project_listing) }

      it 'destroys the record' do
        listing = create(:project_listing)
        expect { delete :destroy, id: listing }.to change { ProjectListing.count }.by(-1)
      end
      it { should redirect_to :root }
      it { should_not set_the_flash }
    end
  end
end
