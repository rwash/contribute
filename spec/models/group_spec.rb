require 'spec_helper'

describe Group do
	describe 'approvals' do
		before(:all) do
			@group = FactoryGirl.create(:group, :open => true, :admin_user_id => 1)
			@project = FactoryGirl.create(:project, :state => 'active')
			@approval = FactoryGirl.create(:approval, :project_id => @project.id)
			@group.approvals << @approval
		end
		
		after(:all) do
			Group.delete_all
			Project.delete_all
			Approval.delete_all
		end
		
		it 'Approves all approvals when changes to open group' do
			@group.approve_all
			assert @group.projects.include?(Project.find(@approval.project_id)), "Project was not added."
		end	
	end
end