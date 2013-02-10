require 'spec_helper'

describe Group do

  # Abilities
  describe 'Abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:group) { build :group }

    context 'when not signed in' do
      let(:user) { nil }

      it { should be_able_to :read, group }
      it { should be_able_to :show, group }
      it { should be_able_to :index, group }
      it { should_not be_able_to :create, group }
      it { should_not be_able_to :submit_add, group }
      it { should_not be_able_to :new_add, group }
      it { should_not be_able_to :edit, group }
      it { should_not be_able_to :update, group }
      it { should_not be_able_to :admin, group }
      it { should_not be_able_to :destroy, group }
    end

    context 'when signed in' do
      let(:user) { create :user }

      it { should be_able_to :read, group }
      it { should be_able_to :show, group }
      it { should be_able_to :index, group }
      it { should be_able_to :create, group }
      it { should be_able_to :submit_add, group }
      it { should be_able_to :new_add, group }
      it { should_not be_able_to :edit, group }
      it { should_not be_able_to :update, group }
      it { should_not be_able_to :admin, group }
      it { should_not be_able_to :destroy, group }
    end

    context 'when user owns group' do
      let(:user) { group.admin_user }

      it { should be_able_to :read, group }
      it { should be_able_to :show, group }
      it { should be_able_to :index, group }
      it { should be_able_to :create, group }
      it { should be_able_to :submit_add, group }
      it { should be_able_to :new_add, group }
      it { should be_able_to :edit, group }
      it { should be_able_to :update, group }
      it { should be_able_to :admin, group }
      it { should be_able_to :destroy, group }
    end

    context 'when signed in as admin' do
      let(:user) { create :user, admin: true }

      it { should be_able_to :read, group }
      it { should be_able_to :show, group }
      it { should be_able_to :index, group }
      it { should be_able_to :create, group }
      it { should be_able_to :submit_add, group }
      it { should be_able_to :new_add, group }
      it { should be_able_to :edit, group }
      it { should be_able_to :update, group }
      it { should be_able_to :admin, group }
      it { should be_able_to :destroy, group }
    end
  end

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_presence_of :admin_user }

  describe 'approvals' do
    let(:project) { create :project, state: 'active' }
    let(:approval) { create :approval, project: project }
    let(:group) { approval.group }

    it 'Approves all approvals when changes to open group' do
      group.approve_all
      expect(group.projects).to include approval.project
    end
  end
end
