require 'spec_helper'

describe Group do

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_presence_of :admin_user }

  describe 'approvals' do
    let(:project) { Factory :project, state: 'active' }
    let(:approval) { Factory :approval, project: project }
    let(:group) { approval.group }

    it 'Approves all approvals when changes to open group' do
      group.approve_all
      expect(group.projects).to include approval.project
    end
  end
end
