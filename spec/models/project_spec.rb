require 'spec_helper'

describe Project do

  describe 'name' do
    it 'is required' do
      project = FactoryGirl.build(:project, name: '')
      expect(project.save).to be_false
    end

    it 'validates uniqueness' do
      project = FactoryGirl.create(:project)
      project2 = FactoryGirl.build(:project, name: project.name)	
      expect(project2.save).to be_false
    end

    it 'can only contain letters and numbers' do
      project = FactoryGirl.build(:project, name: "Jake is cool 1234")
      expect(project.save).to be_true
      project2 = FactoryGirl.build(:project, name: 'Sup D@wg.jpeg')
      expect(project2.save).to be_false
    end

    it 'fails with max length + 1' do
      project = FactoryGirl.build(:project, name: "a" * (Project::MAX_NAME_LENGTH + 1))
      expect(project.save).to be_false
    end

    it 'saves with max length' do
      project = FactoryGirl.build(:project, name: "a" * (Project::MAX_NAME_LENGTH))
      expect(project.save).to be_true
    end
  end

  describe 'short description' do
    it 'is required' do
      project = FactoryGirl.build(:project, short_description: '')
      expect(project.save).to be_false
    end

    it 'fails with max length + 1' do
      project = FactoryGirl.build(:project, short_description: "a" * (Project::MAX_SHORT_DESC_LENGTH + 1))
      expect(project.save).to be_false
    end

    it 'saves with max length' do
      project = FactoryGirl.build(:project, short_description: "a" * (Project::MAX_SHORT_DESC_LENGTH))
      expect(project.save).to be_true
    end
  end

  describe 'long description' do
    it 'is required' do
      project = FactoryGirl.build(:project, long_description: '')
      expect(project.save).to be_false
    end

    it 'fails with max length + 1' do
      project = FactoryGirl.build(:project, long_description: "a" * (Project::MAX_LONG_DESC_LENGTH + 1))
      expect(project.save).to be_false
    end

    it 'saves with max length' do
      project = FactoryGirl.build(:project, long_description: "a" * (Project::MAX_LONG_DESC_LENGTH))#2
      expect(project.save).to be_true
    end
  end

  describe 'funding goal' do
    it "is required" do
      project = FactoryGirl.build(:project, funding_goal: "")
      expect(project.save).to be_false
    end
    it "fails below minimum" do
      project = FactoryGirl.build(:project, funding_goal: (Project::MIN_FUNDING_GOAL - 1))
      expect(project.save).to be_false
    end
    it "takes funding_goals with commas" do
      project = FactoryGirl.build(:project, funding_goal: '9,999,999')#3
      expect(project.save).to be_true
    end
    it "is an integer" do
      project = FactoryGirl.build(:project, funding_goal: 5.5)
      expect(project.save).to be_false
    end
  end

  describe 'end date' do
    it 'succeeds with properly formatted date' do
      project = FactoryGirl.build(:project, end_date: '03/12/2020')#4
      expect(project.save).to be_true
      expect(project.end_date.month).to eq 3
      expect(project.end_date.day).to eq 12
      expect(project.end_date.year).to eq 2020
    end
    it 'fails with improperly formatted date' do
      project = FactoryGirl.build(:project, end_date: '03-12-2020')
      expect(project.save).to be_false
    end	

    it 'succeeds when equal to tomorrow' do
      project = FactoryGirl.build(:project, end_date: Date.today + 1)#5
      expect(project.save).to be_true
    end
    #This tests validate_end_date
    it 'fails when equal to today' do
      project = FactoryGirl.build(:project, end_date: Date.today)
      expect(project.save).to be_false
    end
  end

  describe 'user' do
    it 'id is required' do
      project = FactoryGirl.build(:project, user_id: '')
      expect(project.save).to be_false
    end
  end

  describe 'category id' do
    it 'is required' do
      project = FactoryGirl.build(:project, category_id: '')
      expect(project.save).to be_false
    end
  end

  describe 'payment account id' do
    it 'is required' do
      project = FactoryGirl.build(:project, payment_account_id: '')
      expect(project.save).to be_false
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
      expect(project.contributions_total).to eq sum
    end

    it 'contributions_percentage is correct' do
      sum = contributions.map{|c| c.amount}.inject(:+)
      expect(project.contributions_percentage).to eq((sum.to_f/project.funding_goal * 100).to_i)
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
      expect(project.name.gsub(/\W/, '-')).to eq project.to_param
      project.delete
    end
  end
  #End Methods
end
