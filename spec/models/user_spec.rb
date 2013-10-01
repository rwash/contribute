require 'spec_helper'

describe User do
  # Validations
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should_not allow_value('invalid_email').for :email }
    it { should allow_value('valid@example.com').for :email }
  end

  describe 'abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:member) { create :user }

    context 'when not signed in' do
      let(:user) { nil }

      it { should_not be_able_to :read, member }
    end

    context 'when signed in' do
      let(:user) { create :user }

      it { should_not be_able_to :read, member }
      it { should be_able_to :read, user }
    end

    context 'when signed in as admin' do
      let(:user) { create :user, admin: true }

      it { should be_able_to :read, member }
      it { should be_able_to :read, user }

      it { should be_able_to :read, User }
    end
  end
end
