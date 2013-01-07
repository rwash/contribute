require "spec_helper"

describe EmailManager do
	before(:all) do
		User.delete_all
		Project.delete_all
		Contribution.delete_all
	end

	after(:each) do
		User.delete_all
		Project.delete_all
		Contribution.delete_all
	end

	it "add project" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project, :user_id => user.id)

		EmailManager.add_project(project).deliver
	
		#The [] is a known quirk with deliveries emails
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "contribute to project" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :user_id => user.id, :project_id => project.id)

		EmailManager.contribute_to_project(contribution).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "edit contribution" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project)
		old_contribution = FactoryGirl.create(:contribution, :user_id => user.id, :project_id => project.id, :status => ContributionStatus::CANCELLED)
		contribution = FactoryGirl.create(:contribution, :user_id => user.id, :project_id => project.id)

		EmailManager.edit_contribution(old_contribution, contribution).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "contribution cancelled" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :user_id => user.id, :project_id => project.id)

		EmailManager.contribution_cancelled(contribution).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "contribution successful" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :user_id => user.id, :project_id => project.id)

		EmailManager.contribution_successful(contribution).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "failed retries" do
		contribution = FactoryGirl.create(:contribution, :status => ContributionStatus::RETRY_CANCEL)
		contribution2 = FactoryGirl.create(:contribution, :status => ContributionStatus::PENDING)
		argArray = [ contribution, contribution2 ]

		EmailManager.failed_retries(argArray).deliver

		#TODO: Admin address
		last_email.subject.should match(Date.today.to_s)
	end

	it "project funded to owner" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project, :user_id => user.id)

		EmailManager.project_funded_to_owner(project).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "project not funded to owner" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project, :user_id => user.id)

		EmailManager.project_not_funded_to_owner(project).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "project funded to contributor" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :user_id => user.id, :project_id => project.id)

		EmailManager.project_funded_to_contributor(contribution).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "project not funded to contributor" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :user_id => user.id, :project_id => project.id)

		EmailManager.project_not_funded_to_contributor(contribution).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "project deleted to owner" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project, :user_id => user.id)

		EmailManager.project_deleted_to_owner(project).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "project deleted to contributor" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :user_id => user.id, :project_id => project.id)

		EmailManager.project_deleted_to_contributor(contribution).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
	end

	it "unretriable cancel to admin" do
		contribution = FactoryGirl.create(:contribution)
		error = AmazonError.find_by_error("TransactionDenied")

		EmailManager.unretriable_cancel_to_admin(error, contribution).deliver

		#TODO: To admin address
		last_email.subject.should match(contribution.id.to_s)
		last_email.body.encoded.should match(contribution.id.to_s)
		last_email.body.encoded.should match(error.description)
	end

	it "unretriable payment to user" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :user_id => user.id, :project_id => project.id)
		error = AmazonError.find_by_error("UnverifiedEmailAddress_Sender")

		EmailManager.unretriable_payment_to_user(error, contribution).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
		last_email.body.encoded.should match(error.description)
	end

	it "unretriable payment to admin" do
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :project_id => project.id)
		error = AmazonError.find_by_error("UnverifiedEmailAddress_Recipient")

		EmailManager.unretriable_payment_to_admin(error, contribution).deliver

		#TODO: Admin	
		last_email.subject.should match(contribution.id.to_s)
		last_email.body.encoded.should match(contribution.id.to_s)
		last_email.body.encoded.should match(error.description)
	end

	it "cancelled payment to admin" do
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :project_id => project.id)
		error = AmazonError.find_by_error("InvalidTokenId_Sender")

		EmailManager.cancelled_payment_to_admin(contribution).deliver
	
		#TODO: Admin	
		last_email.subject.should match(contribution.id.to_s)
		last_email.body.encoded.should match(contribution.id.to_s)
		last_email.body.encoded.should match(project.name)
	end

	it "failed payment to user" do
		user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :user_id => user.id, :project_id => project.id)
		error = AmazonError.find_by_error("UnverifiedEmailAddress_Sender")

		EmailManager.failed_payment_to_user(contribution).deliver
	
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.body.encoded.should match(user.name)
		last_email.body.encoded.should match(project.name)
	end

	it "failed status to admin" do
		project = FactoryGirl.create(:project)
		contribution = FactoryGirl.create(:contribution, :project_id => project.id)
		error = AmazonError.find_by_error("InvalidTokenId_Sender")

		EmailManager.failed_status_to_admin(error, contribution).deliver
	
		#TODO: Admin	
		last_email.subject.should match(contribution.id.to_s)
		last_email.body.encoded.should match(contribution.id.to_s)
		last_email.body.encoded.should match(error.description)
	end
	
	it "project update to contributor" do
		project = FactoryGirl.create(:project)
		user = FactoryGirl.create(:user)
		contribution = FactoryGirl.create(:contribution, :project_id => project.id, :user_id => user.id)
		update = FactoryGirl.create(:update, :project_id => project.id, :user_id => user.id)
		
		EmailManager.project_update_to_contributor(update, contribution).deliver
		
		last_email.to.should == [user.email] 
		last_email.subject.should match(project.name)
		last_email.subject.should match(update.title)
		last_email.body.encoded.should match(user.name)
		last_email.body.encoded.should match(project.name)
	end

	it "project_to_group_approval" do # approval, project, group, project owner, group owner,
		proj_user = FactoryGirl.create(:user)
		group_user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project, :user_id => proj_user.id)
		group = FactoryGirl.create(:group, :admin_user_id => group_user.id, :open => false)
		approval = FactoryGirl.create(:approval, :project_id => project.id, :group_id => group.id)
		
		EmailManager.project_to_group_approval(approval, project, group).deliver
		
		last_email.to.should == [group_user.email]
		last_email.subject.should match(project.name)
		last_email.subject.should match(group.name)
		last_email.body.encoded.should match(group_user.name)
	end
	
	it "group_reject_project" do # approval project group, project owner
		proj_user = FactoryGirl.create(:user)
		group_user = FactoryGirl.create(:user)
		project = FactoryGirl.create(:project, :user_id => proj_user.id)
		group = FactoryGirl.create(:group, :admin_user_id => group_user.id, :open => false)
		approval = FactoryGirl.create(:approval, :project_id => project.id, :group_id => group.id, :reason => "I hate you.")
		
		EmailManager.group_reject_project(approval, project, group).deliver
		
		last_email.to.should == [proj_user.email]
		last_email.subject.should match(project.name)
		last_email.subject.should match(group.name)
		last_email.body.encoded.should match(proj_user.name)
		last_email.body.encoded.should match(approval.reason)
	end

end
