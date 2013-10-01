require 'spec_helper'

describe Update do
  # Validations
  it { should validate_presence_of :title }
  it { should validate_presence_of :content }
  it { should validate_presence_of :user }
  it { should validate_presence_of :project }

  # Abilities
  describe 'Abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }

    context 'when not signed in' do
      let(:user) { nil }

      it { should_not be_able_to(:create, build(:update)) }
    end

    context 'when signed in' do
      let(:user) { create :user }

      context 'when user owns the project' do
        let(:project) { create :active_project, owner: user }

        it { should be_able_to(:create, project.updates.new) }
      end

      context 'when user does not own the project' do
        let(:project) { create :active_project }

        it { should_not be_able_to(:create, project.updates.new) }
      end

      context 'when signed in as admin' do
        let(:user) { create :user, admin: true }
        let(:project) { create :active_project }

        it { should be_able_to(:create, project.updates.new) }
      end
    end

  end
end
