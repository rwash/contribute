require 'spec_helper'

describe Group do
  describe 'approvals' do

    let(:project) { Factory :project, state: 'active' }
    let!(:approval) { Factory :approval, project: project }

    it 'Approves all approvals when changes to open group' do
      group = approval.group
      group.approve_all
      expect(group.projects).to include approval.project
    end
  end
end
