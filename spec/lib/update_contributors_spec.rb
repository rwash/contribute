require "spec_helper"
require "tasks/update_contributors"

describe UpdateContributors do
  describe "integration tests" do
    it "run works" do

      project = create :active_project, end_date: 1.week.from_now
      update = create :update, email_sent: false, project: project

      Contribution.any_instance.stub(:execute_payment) {}
      Contribution.any_instance.stub(:cancel) {}

      to_funded = create(:contribution, amount: 15, project: project)
      to_funded2 = create(:contribution, amount: 100, project: project)

      EmailManager.stub_chain(:project_update_to_contributor, deliver: true)
      update.email_sent = true

      EmailManager.should_receive(:project_update_to_contributor).with(update, to_funded).once
      EmailManager.should_receive(:project_update_to_contributor).with(update, to_funded2).once

      UpdateContributors.run
    end
  end
end
