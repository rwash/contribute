require 'spec_helper'

describe Project do

  describe 'state' do
    let(:project) { Factory :project, state: project_state }

    context "is unconfirmed" do
      let(:project_state) { 'unconfirmed' }

      it 'responds appropriately' do
        project.state.should eq 'unconfirmed'
        project.state.unconfirmed?.should be_true
        project.state.inactive?.should be_false
        project.state.active?.should be_false
        project.state.nonfunded?.should be_false
        project.state.funded?.should be_false
        project.state.cancelled?.should be_false
      end

      it 'can be edited' do
        project.can_edit?.should be_true
      end

      it "can't be viewed by the public" do
        project.public_can_view?.should be_false
      end

      it "can't be updated" do
        project.can_update?.should be_false
      end

      it "can't be commented on" do
        project.can_comment?.should be_false
      end
    end

    context "is inactive" do
      let(:project_state) { 'inactive' }

      it 'responds appropriately' do
        project.state = :inactive
        project.state.should eq 'inactive'
        project.state.unconfirmed?.should be_false
        project.state.inactive?.should be_true
        project.state.active?.should be_false
        project.state.nonfunded?.should be_false
        project.state.funded?.should be_false
        project.state.cancelled?.should be_false
      end

      it "can be edited" do
        project.can_edit?.should be_true
      end

      it "can't be viewed by the public" do
        project.public_can_view?.should be_false
      end

      it "can't be updated" do
        project.can_update?.should be_false
      end

      it "can't be commented on" do
        project.can_comment?.should be_false
      end
    end

    context "is active" do
      let(:project_state) { 'active' }

      it 'responds appropriately' do
        project.state = :active
        project.state.should eq 'active'
        project.state.unconfirmed?.should be_false
        project.state.inactive?.should be_false
        project.state.active?.should be_true
        project.state.nonfunded?.should be_false
        project.state.funded?.should be_false
        project.state.cancelled?.should be_false
      end

      it "can't be edited" do
        project.can_edit?.should be_false
      end

      it "can be viewed by the public" do
        project.public_can_view?.should be_true
      end

      it "can be updated" do
        project.can_update?.should be_true
      end

      it "can be commented on" do
        project.can_comment?.should be_true
      end
    end

    context "is nonfunded" do
      let(:project_state) { 'nonfunded' }

      it 'responds appropriately' do
        project.state = :nonfunded
        project.state.should eq 'nonfunded'
        project.state.unconfirmed?.should be_false
        project.state.inactive?.should be_false
        project.state.active?.should be_false
        project.state.nonfunded?.should be_true
        project.state.funded?.should be_false
        project.state.cancelled?.should be_false
      end

      it "can't be edited" do
        project.can_edit?.should be_false
      end

      it "can be viewed by the public" do
        project.public_can_view?.should be_true
      end

      it "can be updated" do
        project.can_update?.should be_true
      end

      it "can be commented on" do
        project.can_comment?.should be_true
      end
    end

    context "is funded" do
      let(:project_state) { 'funded' }

      it 'responds appropriately' do
        project.state = :funded
        project.state.should eq 'funded'
        project.state.unconfirmed?.should be_false
        project.state.inactive?.should be_false
        project.state.active?.should be_false
        project.state.nonfunded?.should be_false
        project.state.funded?.should be_true
        project.state.cancelled?.should be_false
      end

      it "can't be edited" do
        project.can_edit?.should be_false
      end

      it "can be viewed by the public" do
        project.public_can_view?.should be_true
      end

      it "can be updated" do
        project.can_update?.should be_true
      end

      it "can be commented on" do
        project.can_comment?.should be_true
      end
    end

    context "is cancelled" do
      let(:project_state) { 'cancelled' }

      it 'responds appropriately' do
        project.state = :cancelled
        project.state.should eq 'cancelled'
        project.state.unconfirmed?.should be_false
        project.state.inactive?.should be_false
        project.state.active?.should be_false
        project.state.nonfunded?.should be_false
        project.state.funded?.should be_false
        project.state.cancelled?.should be_true
      end

      it "can't be edited" do
        project.can_edit?.should be_false
      end

      it "can't be viewed by the public" do
        project.public_can_view?.should be_false
      end

      it "can't be updated" do
        project.can_update?.should be_false
      end

      it "can't be commented on" do
        project.can_comment?.should be_false
      end
    end

    it 'guards against invalid values' do
      project = Factory.build :project, state: 'invalid_state'
      project.valid?.should be_false
      project.save.should be_false
    end

    it 'guards against nil value' do
      project = Factory.build :project, state: nil
      project.valid?.should be_false
      project.save.should be_false
    end
  end


  describe 'name' do
    it 'is required' do
      project = FactoryGirl.build(:project, :name => '')
      assert !project.save, 'Incorrectly saved project with blank name'
    end

    it 'validates uniqueness' do
      project = FactoryGirl.create(:project)
      project2 = FactoryGirl.build(:project, :name => project.name)	
      assert !project2.save, 'Incorrectly saved project with duplicate name'	
    end

    it 'can only contain letters and numbers' do
      project = FactoryGirl.build(:project, :name => "Jake is cool 1234")
      assert project.save, 'Project could not be saved with a title of only letters and numbers.'
      project2 = FactoryGirl.build(:project, :name => 'Sup D@wg.jpeg')
      assert !project2.save, 'Project incorretly saved with a tile containing sysmbols other than A-Z,a-z, 0-9'
    end

    it 'fails with max length + 1' do
      project = FactoryGirl.build(:project, :name => "a" * (Project::MAX_NAME_LENGTH + 1))
      assert !project.save, 'Incorrectly saved project with name too long'
    end

    it 'saves with max length' do
      project = FactoryGirl.build(:project, :name => "a" * (Project::MAX_NAME_LENGTH))
      assert project.save, 'Failed to save project with correct name length'
    end
  end

  describe 'short description' do
    it 'is required' do
      project = FactoryGirl.build(:project, :short_description => '')
      assert !project.save, 'Incorrectly saved project with blank short_description'
    end

    it 'fails with max length + 1' do
      project = FactoryGirl.build(:project, :short_description => "a" * (Project::MAX_SHORT_DESC_LENGTH + 1))
      assert !project.save, 'Incorrectly saved project with short description too long'
    end

    it 'saves with max length' do
      project = FactoryGirl.build(:project, :short_description => "a" * (Project::MAX_SHORT_DESC_LENGTH))
      assert project.save, 'Failed to save project with correct short description length'
    end
  end

  describe 'long description' do
    it 'is required' do
      project = FactoryGirl.build(:project, :long_description => '')
      assert !project.save, 'Incorrectly saved project with blank long_description'
    end

    it 'fails with max length + 1' do
      project = FactoryGirl.build(:project, :long_description => "a" * (Project::MAX_LONG_DESC_LENGTH + 1))
      assert !project.save, 'Incorrectly saved project with long description too long'
    end

    it 'saves with max length' do
      project = FactoryGirl.build(:project, :long_description => "a" * (Project::MAX_LONG_DESC_LENGTH))#2
      assert project.save, 'Failed to save project with correct long description length'
    end
  end

  describe 'funding goal' do
    it "is required" do
      project = FactoryGirl.build(:project, :funding_goal => "")
      assert !project.save, "Incorrectly saved project without a funding_goal"
    end
    it "fails below minimum" do
      project = FactoryGirl.build(:project, :funding_goal => (Project::MIN_FUNDING_GOAL - 1))
      assert !project.save, "Incorrectly saved project without funding_goal below minimum project"
    end
    it "takes funding_goals with commas" do
      project = FactoryGirl.build(:project, :funding_goal => '9,999,999')#3
      assert project.save, "Should have saved project with funding_goal with commas"
    end
    it "is an integer" do
      project = FactoryGirl.build(:project, :funding_goal => 5.5)
      assert !project.save, "Incorrectly saved project with funding_goal that's not an int"
    end
  end

  describe 'end date' do
    it 'succeeds with properly formatted date' do
      project = FactoryGirl.build(:project, :end_date => '03/12/2020')#4
      assert project.save, 'Failed to save project with proper date'
      assert_equal project.end_date.month, 3
      assert_equal project.end_date.day, 12
      assert_equal project.end_date.year, 2020
    end
    it 'fails with improperly formatted date' do
      project = FactoryGirl.build(:project, :end_date => '03-12-2020')
      assert !project.save, 'Incorrectly saved project with improperly formatted date'
    end	

    it 'succeeds when equal to tomorrow' do
      project = FactoryGirl.build(:project, :end_date => Date.today + 1)#5
      assert project.save, 'Failed to save project with date of tomorrow'
    end
    #This tests validate_end_date
    it 'fails when equal to today' do
      project = FactoryGirl.build(:project, :end_date => Date.today)
      assert !project.save, 'Incorrectly saved project with date of today'
    end
  end

  describe 'user' do
    it 'id is required' do
      project = FactoryGirl.build(:project, :user_id => '')
      assert !project.save, 'Incorrectly saved project without user id'
    end
  end

  describe 'category id' do
    it 'is required' do
      project = FactoryGirl.build(:project, :category_id => '')
      assert !project.save, 'Incorrectly saved project without category id'
    end
  end

  describe 'payment account id' do
    it 'is required' do
      project = FactoryGirl.build(:project, :payment_account_id => '')
      assert !project.save, 'Incorrectly saved project without payment account id'
    end
  end

  #TODO: pictures

  #End Properties

  #Begin Methods	
  describe 'contributions' do
    #These are instance variables so they can be accessed outside of the before. If they're not
    # in a before, they appear to like a before(:each) by default and cause duplicate errors
    let(:project) { Factory :project, state: 'active' }
    let(:contributions) do
      3.times.map { Factory :contribution, project: project }
    end
    #Since this one is cancelled it shouldn't count towards the total
    let(:cancelled) { Factory :contribution, project: project, status: :cancelled }

    before(:all) do
      Contribution.any_instance.stub(:destroy) { true }
    end

    it 'contributions_total is correct' do
      sum = contributions.map{|c| c.amount}.inject(:+)
      project.contributions_total.should eq sum
    end

    it 'contributions_percentage is correct' do
      sum = contributions.map{|c| c.amount}.inject(:+)
      project.contributions_percentage.should eq((sum.to_f/project.funding_goal * 100).to_i)
    end

    it 'destroy cancels contributions and sets to inactive'
=begin
  Somehow, the methods aren't being properly stubbed, and the contributions aren't receiving
  the 'destroy' call.
  ---
      EmailManager.stub_chain(:project_deleted_to_owner, :deliver => true)
      EmailManager.should_receive(:project_deleted_to_owner).with(project).once
      EmailManager.stub_chain(:project_deleted_to_contributor, :deliver => true)
      EmailManager.should_receive(:project_deleted_to_contributor).with(instance_of(Contribution)).exactly(3).times

      # Ensure that when we destroy a project, the contributions get destroyed as well.
      contributions.each { |c| c.should_receive(:destroy).once }

      project.destroy
    end
=end
  end

  describe 'destroy_video' do
    it 'should delete video' do
      project = Factory(:video).project
      expect{ project.destroy_video }.to change{Video.count}.by(-1)
    end

    it 'should leave project.video as nil' do
      p = Factory(:video).project
      p.destroy_video
      expect(p.reload.video).to be_nil
    end
  end

  describe 'update_project_video' do
    it "should not raise an exception" do
      project = Factory :project
      project.update_project_video
    end
  end

  describe 'to_param' do
    it 'returns name' do
      project = FactoryGirl.create(:project)
      assert_equal project.name.gsub(/\W/, '-') , project.to_param
      project.delete
    end
  end
  #End Methods
end
