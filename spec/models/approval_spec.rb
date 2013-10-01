require 'spec_helper'

describe Approval do
  # Abilities
  describe 'Abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:group) { build_stubbed :group }
    let(:project) { build_stubbed :project }
    let(:approval) { build :approval, project: project, group: group }

    context 'when not signed in' do
      let(:user) { nil }

      it { should_not be_able_to :approve, approval }
      it { should_not be_able_to :reject, approval }
    end

    context 'when signed in' do
      let(:user) { create :user }

      it { should_not be_able_to :approve, approval }
      it { should_not be_able_to :reject, approval }
    end

    context 'when user owns group' do
      let(:user) { group.owner }

      it { should be_able_to :approve, approval }
      it { should be_able_to :reject, approval }
    end

    context 'when signed in as admin' do
      let(:user) { create :user, admin: true }

      it { should be_able_to :approve, approval }
      it { should be_able_to :reject, approval }
    end
  end

  it { should validate_presence_of :group }
  it { should validate_presence_of :project }
  it { should ensure_inclusion_of(:status).in_array [:pending, :approved, :rejected] }

  it "has a default status of 'pending'" do
    Approval.new.status.should eq :pending
  end
end
