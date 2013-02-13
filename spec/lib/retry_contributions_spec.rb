require "spec_helper"
require "tasks/retry_contributions"

describe RetryContributions do
  describe "integration run tests" do
    before(:all) do
      Contribution.delete_all
      Project.delete_all
      User.delete_all
    end

    it "success tests" do
      user = create(:user)
      project = create(:project)

      Contribution.any_instance.stub(:update_status) {}
      Contribution.any_instance.stub(:execute_payment) {}
      Contribution.any_instance.stub(:cancel) {}

      success = create(:contribution, status: :success, retry_count: 0)
      pending = create(:contribution, status: :pending, retry_count: 0)
      retry_cancel = create(:contribution, status: :retry_cancel, retry_count: 0)
      retry_pay = create(:contribution, status: :retry_pay, retry_count: 0)

# TODO: Can't get should_receives to work on objects, as opposed to static classes
# Tried stubbing on the object itself and should receiving on Contribution. No luck.
#      pending.should_receive(:update_status).once
#      retry_cancel.should_receive(:cancel).once
#      retry_pay.should_receive(:execute_payment).once

      RetryContributions.run
    end

    it "failure tests" do
      user = create(:user)
      project = create(:project)

      Contribution.any_instance.stub(:update_status) {}
      Contribution.any_instance.stub(:execute_payment) {}
      Contribution.any_instance.stub(:cancel) {}

      success = create(:contribution, status: :success, retry_count: 4)
      pending = create(:contribution, status: :pending, retry_count: 4)
      retry_cancel = create(:contribution, status: :retry_cancel, retry_count: 4)
      retry_pay = create(:contribution, status: :retry_pay, retry_count: 4)

      EmailManager.stub_chain(:failed_retries, deliver: true)
      expectedArray = [ pending, retry_pay, retry_cancel ]
      EmailManager.should_receive(:failed_retries).with(expectedArray).once

      RetryContributions.run
    end
  end
end
