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

      it { should_not be_able_to(:create, Factory.build(:update)) }
    end

    context 'when signed in' do
      let(:user) { Factory :user }

      context 'when user owns the project' do
        let(:project) { Factory :project, user: user, state: :active }

        it { should be_able_to(:create, project.updates.new) }
      end

      context 'when user does not own the project' do
        let(:project) { Factory :project, state: :active }

        it { should_not be_able_to(:create, project.updates.new) }
      end

      context 'when signed in as admin' do
        let(:user) { Factory :user, admin: true }
        let(:project) { Factory :project, state: :active }

        it { should be_able_to(:create, project.updates.new) }
      end
    end

  end
end
