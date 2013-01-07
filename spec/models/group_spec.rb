require 'spec_helper'

describe Group do
	describe 'approvals' do
    let(:group) { Factory :group }
    let(:project) { Factory :project, state: 'active' }
    let(:approval) { Factory :approval, project_id: project.id }

		before(:all) do
			group.approvals << approval
		end
		
		after(:all) do
			Group.delete_all
			Project.delete_all
			Approval.delete_all
		end
		
		it 'Approves all approvals when changes to open group' do
			group.approve_all
			assert group.projects.include?(Project.find(approval.project_id)), "Project was not added."
		end	
	end
end
