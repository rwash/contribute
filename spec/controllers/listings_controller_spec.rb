require 'spec_helper'
require 'controller_helper'

describe ListingsController do
  include Devise::TestHelpers
  render_views

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

  describe 'POST sort' do
    let(:list) { create :project_list }
    let(:listings) do
     2.times.map { create :project_listing, list: list }
    end

    context 'without permission' do
      before { @ability.stub!(:can?).and_return(false) }
      before { post :sort, project_listing: [listings[1].id, listings[0].id] }

      it 'should not reorder the listings' do
        list.reload.listings.order('position').map(&:id).should eq [listings[0].id, listings[1].id]
      end
    end

    context 'with permission' do
      before { @ability.stub!(:can?).and_return(true) }
      before { post :sort, project_listing: [listings[1].id, listings[0].id] }

      it 'should reorder the listings' do
        list.reload.listings.order('position').map(&:id).should eq [listings[1].id, listings[0].id]
      end
      it { should_not set_the_flash }
    end
  end
end
