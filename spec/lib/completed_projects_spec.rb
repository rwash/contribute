require "spec_helper"
require "tasks/completed_projects"

describe CompletedProjects do
  describe "integration tests" do
    before(:all) do
      Contribution.delete_all
      Project.delete_all
      User.delete_all
    end

    it "run works" do
      funded = build(:project, state: 'active', funding_goal: 10, end_date: (Date.today - 1))
      #Validation prevents projects with an end_date before or on today. So skip validation.
      funded.save(validate: false)
      not_funded = build(:project, state: 'active', funding_goal: 100000, end_date: (Date.today - 1))
      not_funded.save(validate: false)
      ignore = build(:project, funding_goal: 100000, end_date: (Date.today - 3))
      ignore.save(validate: false)
      ignore2 = build(:project, funding_goal: 100000, end_date: Date.today)
      ignore2.save(validate: false)

      Contribution.any_instance.stub(:execute_payment) {}
      Contribution.any_instance.stub(:cancel) {}

      to_funded = create(:contribution, amount: 15, project: funded)
      to_funded2 = create(:contribution, amount: 100, project: funded)
      to_not_funded = create(:contribution, amount: 5, project: not_funded)
      ignore = create(:contribution, status: :cancelled, project: not_funded)

      EmailManager.stub_chain(:project_not_funded_to_owner, deliver: true)
      EmailManager.stub_chain(:project_funded_to_owner, deliver: true)
      EmailManager.stub_chain(:project_not_funded_to_contributor, deliver: true)
      EmailManager.stub_chain(:project_funded_to_contributor, deliver: true)

      EmailManager.should_receive(:project_not_funded_to_owner).with(not_funded).once
      EmailManager.should_receive(:project_funded_to_owner).with(funded).once
      EmailManager.should_receive(:project_not_funded_to_contributor).with(to_not_funded).once
      EmailManager.should_receive(:project_funded_to_contributor).with(to_funded).once
      EmailManager.should_receive(:project_funded_to_contributor).with(to_funded2).once

      # TODO: Can't get should_receives to work on objects, as opposed to static classes
      # Tried stubbing on the object itself and should receiving on Contribution. No luck.
      #      expect(to_not_funded).to_receive(:cancel).once
      #      expect(to_funded).to_receive(:execute_payment).once
      #      expect(to_funded2).to_receive(:execute_payment).once

      CompletedProjects.run

      expect(funded.reload.state).to eq :funded
      expect(not_funded.reload.state).to eq :nonfunded
    end

    it "run all works" do
      funded = build(:project, state: 'active', funding_goal: 15, end_date: (Date.today - 1))
      #Validation prevents projects with an end_date before or on today. So skip validation.
      funded.save(validate: false)
      not_funded = build(:project, state: 'active', funding_goal: 100000, end_date: (Date.today - 1))
      not_funded.save(validate: false)
      funded_not_ignored = build(:project, state: 'active', funding_goal: 95, end_date: (Date.today - 3))
      funded_not_ignored.save(validate: false)
      ignore2 = build(:project, funding_goal: 100000, end_date: Date.today)
      ignore2.save(validate: false)

      Contribution.any_instance.stub(:execute_payment) {}
      Contribution.any_instance.stub(:cancel) {}

      to_funded = create(:contribution, amount: 15, project: funded)
      to_funded_not_ignored = create(:contribution, amount: 100, project: funded_not_ignored)
      to_not_funded = create(:contribution, amount: 5, project: not_funded)
      ignore = create(:contribution, status: :cancelled, project: not_funded)

      EmailManager.stub_chain(:project_not_funded_to_owner, deliver: true)
      EmailManager.stub_chain(:project_funded_to_owner, deliver: true)
      EmailManager.stub_chain(:project_not_funded_to_contributor, deliver: true)
      EmailManager.stub_chain(:project_funded_to_contributor, deliver: true)

      EmailManager.should_receive(:project_not_funded_to_owner).with(not_funded).once
      EmailManager.should_receive(:project_funded_to_owner).with(funded).once
      EmailManager.should_receive(:project_funded_to_owner).with(funded_not_ignored).once
      EmailManager.should_receive(:project_not_funded_to_contributor).with(to_not_funded).once
      EmailManager.should_receive(:project_funded_to_contributor).with(to_funded).once
      EmailManager.should_receive(:project_funded_to_contributor).with(to_funded_not_ignored).once

      # TODO: Can't get should_receives to work on objects, as opposed to static classes
      # Tried stubbing on the object itself and should receiving on Contribution. No luck.
      #      to_not_funded.should_receive(:cancel).once
      #      to_funded.should_receive(:execute_payment).once
      #      to_funded_not_ignored.should_receive(:execute_payment).once

      CompletedProjects.run_all
    end
  end
end
