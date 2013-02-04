require 'spec_helper'

describe ProjectListing do
  let(:listing) { Factory :project_listing }

  it 'contains a reference to a project' do
    expect(listing.project).to be_instance_of Project
    expect(listing.item).to be_instance_of Project
  end
end
