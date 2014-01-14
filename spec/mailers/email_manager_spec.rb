require "spec_helper"

describe EmailManager do
  before(:all) do
    User.delete_all
    Project.delete_all
    Contribution.delete_all
  end

  it "add project" do
    user = create(:user)
    project = create(:project, owner: user)

    EmailManager.add_project(project).deliver

    #The [] is a known quirk with deliveries emails
    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "contribute to project" do
    user = create(:user)
    project = create(:project)
    contribution = create(:contribution, user: user, project: project)

    EmailManager.contribute_to_project(contribution).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "edit contribution" do
    user = create(:user)
    project = create(:project)
    old_contribution = create(:contribution, user: user, project: project, status: :cancelled)
    contribution = create(:contribution, user: user, project: project)

    EmailManager.edit_contribution(old_contribution, contribution).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "contribution cancelled" do
    user = create(:user)
    project = create(:project)
    contribution = create(:contribution, user: user, project: project)

    EmailManager.contribution_cancelled(contribution).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "contribution successful" do
    user = create(:user)
    project = create(:project)
    contribution = create(:contribution, user: user, project: project)

    EmailManager.contribution_successful(contribution).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "project funded to owner" do
    user = create(:user)
    project = create(:project, owner: user)

    EmailManager.project_funded_to_owner(project).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "project not funded to owner" do
    user = create(:user)
    project = create(:project, owner: user)

    EmailManager.project_not_funded_to_owner(project).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "project funded to contributor" do
    user = create(:user)
    project = create(:project)
    contribution = create(:contribution, user: user, project: project)

    EmailManager.project_funded_to_contributor(contribution).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "project not funded to contributor" do
    user = create(:user)
    project = create(:project)
    contribution = create(:contribution, user: user, project: project)

    EmailManager.project_not_funded_to_contributor(contribution).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "project deleted to owner" do
    user = create(:user)
    project = create(:project, owner: user)

    EmailManager.project_deleted_to_owner(project).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "project deleted to contributor" do
    user = create(:user)
    project = create(:project)
    contribution = create(:contribution, user: user, project: project)

    EmailManager.project_deleted_to_contributor(contribution).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
  end

  it "unretriable cancel to admin" do
    pending 'test depends on a TransactionDenied AmazonError in the database'
    contribution = create(:contribution)
    error = AmazonError.find_by_error("TransactionDenied")

    EmailManager.unretriable_cancel_to_admin(error, contribution).deliver

    #TODO: To admin address
    expect(last_email.subject).to match(contribution.id.to_s)
    expect(last_email.body.encoded).to match(contribution.id.to_s)
    expect(last_email.body.encoded).to match(error.description)
  end

  it "unretriable payment to user" do
    pending 'test depends on an UnverifiedEmailAddress_Sender AmazonError in the database'
    user = create(:user)
    project = create(:project)
    contribution = create(:contribution, user: user, project: project)
    error = AmazonError.find_by_error("UnverifiedEmailAddress_Sender")

    EmailManager.unretriable_payment_to_user(error, contribution).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
    expect(last_email.body.encoded).to match(error.description)
  end

  it "unretriable payment to admin" do
    pending 'test depends on an UnverifiedEmailAddress_Recipient AmazonError in the database'
    project = create(:project)
    contribution = create(:contribution, project: project)
    error = AmazonError.find_by_error("UnverifiedEmailAddress_Recipient")

    EmailManager.unretriable_payment_to_admin(error, contribution).deliver

    #TODO: Admin
    expect(last_email.subject).to match(contribution.id.to_s)
    expect(last_email.body.encoded).to match(contribution.id.to_s)
    expect(last_email.body.encoded).to match(error.description)
  end

  it "cancelled payment to admin" do
    project = create(:project)
    contribution = create(:contribution, project: project)
    error = AmazonError.find_by_error("InvalidTokenId_Sender")

    EmailManager.cancelled_payment_to_admin(contribution).deliver

    #TODO: Admin
    expect(last_email.subject).to match(contribution.id.to_s)
    expect(last_email.body.encoded).to match(contribution.id.to_s)
    expect(last_email.body.encoded).to match(project.name)
  end

  it "failed payment to user" do
    user = create(:user)
    project = create(:project)
    contribution = create(:contribution, user: user, project: project)
    error = AmazonError.find_by_error("UnverifiedEmailAddress_Sender")

    EmailManager.failed_payment_to_user(contribution).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.body.encoded).to match(user.name)
    expect(last_email.body.encoded).to match(project.name)
  end

  it "failed status to admin" do
    pending 'test depends on an InvalidTokenId_Sender AmazonError in the database'
    project = create(:project)
    contribution = create(:contribution, project: project)
    error = AmazonError.find_by_error("InvalidTokenId_Sender")

    EmailManager.failed_status_to_admin(error, contribution).deliver

    #TODO: Admin
    expect(last_email.subject).to match(contribution.id.to_s)
    expect(last_email.body.encoded).to match(contribution.id.to_s)
    expect(last_email.body.encoded).to match(error.description)
  end

  it "project update to contributor" do
    project = create(:project)
    user = create(:user)
    contribution = create(:contribution, project: project, user: user)
    update = create(:update, project: project, user: user)

    EmailManager.project_update_to_contributor(update, contribution).deliver

    expect(last_email.to).to eq [user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.subject).to match(update.title)
    expect(last_email.body.encoded).to match(user.name)
    expect(last_email.body.encoded).to match(project.name)
  end

  it "project_to_group_approval" do # approval, project, group, project owner, group owner,
    proj_user = create(:user)
    group_user = create(:user)
    project = create(:project, owner: proj_user)
    group = create(:group, owner: group_user, open: false)
    approval = create(:approval, project: project, group: group)

    EmailManager.project_to_group_approval(approval, project, group).deliver

    expect(last_email.to).to eq [group_user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.subject).to match(group.name)
    expect(last_email.body.encoded).to match(group_user.name)
  end

  it "group_reject_project" do # approval project group, project owner
    proj_user = create(:user)
    group_user = create(:user)
    project = create(:project, owner: proj_user)
    group = create(:group, owner: group_user, open: false)
    approval = create(:approval, project: project, group: group, reason: "I hate you.")

    EmailManager.group_reject_project(approval, project, group).deliver

    expect(last_email.to).to eq [proj_user.email]
    expect(last_email.subject).to match(project.name)
    expect(last_email.subject).to match(group.name)
    expect(last_email.body.encoded).to match(proj_user.name)
    expect(last_email.body.encoded).to match(approval.reason)
  end

end
