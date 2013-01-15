require 'spec_helper'

describe Group do
  describe 'approvals' do

    let(:project) { Factory :project, state: 'active' }
    let!(:approval) { Factory :approval, project: project }

    it 'Approves all approvals when changes to open group' do
      group = approval.group
      group.approve_all
      group.projects.include?(approval.project).should be_true
    end
  end
end
