require 'spec_helper'

describe ProjectListing do
  let(:listing) { create :project_listing }

  it 'contains a reference to a project' do
    expect(listing.item).to be_instance_of Project
  end
end
