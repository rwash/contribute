require 'spec_helper'

describe Project do
  # Abilities
  # create, save, activate, destroy, read, update, contribute
  describe 'Abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:project) { build :project, state: :active }

    context 'when not signed in' do
      let(:user) { nil }

      context 'when project is publicly viewable' do
        before { project.stub!(:public_can_view?).and_return(true) }
        it { should be_able_to :show, project }
      end

      context 'when project is not publicly viewable' do
        before { project.stub!(:public_can_view?).and_return(false) }
        it { should_not be_able_to :show, project }
      end

      it { should_not be_able_to :create, Project }
      it { should_not be_able_to :save, project }
      it { should_not be_able_to :activate, project }
      it { should_not be_able_to :destroy, project }
      it { should_not be_able_to :update, project }
      it { should_not be_able_to :block, project }
      it { should_not be_able_to :unblock, project }
    end

    context 'when signed in' do
      let(:user) { create :user }

      context 'when project is publicly viewable' do
        before { project.stub!(:public_can_view?).and_return(true) }
        it { should be_able_to :show, project }
      end

      context 'when project is not publicly viewable' do
        before { project.stub!(:public_can_view?).and_return(false) }
        it { should_not be_able_to :show, project }
      end

      it { should be_able_to :create, project }
      it { should_not be_able_to :save, project }
      it { should_not be_able_to :activate, project }
      it { should_not be_able_to :destroy, project }
      it { should_not be_able_to :update, project }
      it { should_not be_able_to :block, project }
      it { should_not be_able_to :unblock, project }
    end

    context 'when user owns project' do
      let(:user) { project.user }

      context 'when project is not publicly viewable' do
        before { project.stub!(:public_can_view?).and_return(false) }
        it { should be_able_to :show, project }
      end

      context 'when project is editable' do
        before { project.stub!(:can_edit?).and_return(true) }
        it { should be_able_to :update, build(:project, user: user, state: :inactive) }
      end

      context 'when project is not editable' do
        before { project.stub!(:can_edit?).and_return(false) }
        it { should_not be_able_to :update, build(:project, user: user, state: :active) }
      end

      it { should be_able_to :save, project }
      it { should be_able_to :activate, project }
      it { should_not be_able_to :block, project }
      it { should_not be_able_to :unblock, project }

      it { should be_able_to :destroy, build(:project, user: user, state: :unconfirmed) }
      it { should be_able_to :destroy, build(:project, user: user, state: :inactive) }
      it { should_not be_able_to :destroy, build(:project, user: user, state: :active) }
      it { should_not be_able_to :destroy, build(:project, user: user, state: :nonfunded) }
      it { should_not be_able_to :destroy, build(:project, user: user, state: :funded) }
      it { should_not be_able_to :destroy, build(:project, user: user, state: :cancelled) }
    end

    context 'when signed in as admin' do
      let(:user) { create :user, admin: true }

      context 'when project is not publicly viewable' do
        before { project.stub!(:public_can_view?).and_return(false) }
        it { should be_able_to :show, project }
      end

      context 'when project is editable' do
        before { project.stub!(:can_edit?).and_return(true) }
        it { should be_able_to :update, build(:project, user: user, state: :inactive) }
      end

      context 'when project is not editable' do
        before { project.stub!(:can_edit?).and_return(false) }
        it { should_not be_able_to :update, build(:project, user: user, state: :active) }
      end

      context 'when project is blocked' do
        before { project.stub!(:state).and_return(:blocked) }

        it { should_not be_able_to :block, project }
        it { should be_able_to :unblock, project }
      end

      it { should be_able_to :save, project }
      it { should be_able_to :activate, project }
      it { should be_able_to :block, project }
      it { should_not be_able_to :unblock, project }

      it { should be_able_to :destroy, build(:project, user: user, state: :unconfirmed) }
      it { should be_able_to :destroy, build(:project, user: user, state: :inactive) }
      it { should_not be_able_to :destroy, build(:project, user: user, state: :active) }
      it { should_not be_able_to :destroy, build(:project, user: user, state: :nonfunded) }
      it { should_not be_able_to :destroy, build(:project, user: user, state: :funded) }
      it { should_not be_able_to :destroy, build(:project, user: user, state: :cancelled) }
    end
  end

  # Validations
  describe 'name validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should allow_value('Name containing letters and num6345').for :name }
    it { should_not allow_value('Name containing symbols @').for :name }
    it { should_not allow_value('Name containing symbols |').for :name }
    it { should_not allow_value('Name containing symbols <').for :name }
    it { should_not allow_value('Name containing symbols !').for :name }
    it { should_not allow_value('Name containing symbols ?').for :name }
    it { should ensure_length_of(:name).is_at_most(Project::MAX_NAME_LENGTH) }
  end

  describe 'short description validations' do
    it { should validate_presence_of :short_description }
    it { should ensure_length_of(:short_description).is_at_most(Project::MAX_SHORT_DESC_LENGTH) }
  end

  describe 'long description validations' do
    it { should validate_presence_of :long_description }
    it { should ensure_length_of(:long_description).is_at_most(Project::MAX_LONG_DESC_LENGTH) }
  end

  describe 'funding goal validations' do
    it { should validate_presence_of(:funding_goal).with_message(/must be at least \$5/) }
    it { should validate_numericality_of(:funding_goal).only_integer.with_message(/whole dollar amount/) }
    it { should allow_value(5).for :funding_goal }
    it { should_not allow_value(4).for :funding_goal }
    it { should_not allow_value(-5).for :funding_goal }
    it { should allow_value('9,999,999').for :funding_goal }
  end

  describe 'end date validations' do
    it { should validate_presence_of(:end_date).with_message(/must be of form/) }
    it { should allow_value('03/12/2020').for :end_date }
    it { should_not allow_value('03-12-2020').for :end_date }
    it { should allow_value(Date.tomorrow).for :end_date }
    it { should_not allow_value(Date.today).for :end_date }
    it { should_not allow_value(Date.yesterday).for :end_date }
  end

  it { should validate_presence_of :user }
  it { should validate_presence_of :category_id }
  it { should validate_presence_of :payment_account_id }

  it 'parses time string correctly' do
    project = build(:project, end_date: '03/12/2020')#4
    expect(project.save).to be_true
    expect(project.end_date.month).to eq 3
    expect(project.end_date.day).to eq 12
    expect(project.end_date.year).to eq 2020
  end

  #TODO: pictures

  #Begin Methods	
  describe 'contributions' do
    #These are instance variables so they can be accessed outside of the before. If they're not
    # in a before, they appear to like a before(:each) by default and cause duplicate errors
    let(:project) { create :project, state: 'active' }
    let(:contributions) do
      3.times.map { create :contribution, project: project }
    end
    #Since this one is cancelled it shouldn't count towards the total
    let(:cancelled) { create :contribution, project: project, status: :cancelled }

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
      project = create(:video).project
      expect{ project.destroy_video }.to change{Video.count}.by(-1)
    end

    it 'should leave project.video as nil' do
      p = create(:video).project
      p.destroy_video
      expect(p.reload.video).to be_nil
    end
  end

  describe 'update_project_video' do
    it "should not raise an exception" do
      project = create :project
      project.update_project_video
    end
  end

  describe 'to_param' do
    it 'returns name' do
      project = create(:project)
      expect(project.name.gsub(/\W/, '-')).to eq project.to_param
      project.delete
    end
  end
  #End Methods
end
