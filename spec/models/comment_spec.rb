require 'spec_helper'

describe Comment do
  # Validations

  it { should validate_presence_of :body }
  it { should validate_presence_of :project }
  it { should validate_presence_of :user }

  # Methods
  # its a gem so unless we add anything i think were ok

  describe 'Abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }

    context 'when not signed in' do
      let(:user) { nil }

      it { should_not be_able_to(:create, build(:comment)) }
      it { should_not be_able_to(:destroy, create(:comment)) }
    end

    context 'when signed in' do
      let(:user) { create :user }

      it { should be_able_to(:create, build(:comment)) }
      it { should_not be_able_to(:destroy, create(:comment)) }
    end

    context 'when user owns comment' do
      let(:user) { create :user }
      let(:comment) { create :comment, user: user }

      it { should be_able_to(:create, build(:comment)) }
      it { should be_able_to(:destroy, comment) }
    end

    context 'when signed in as admin' do
      let(:user) { create :user, admin: true }

      it { should be_able_to(:create, build(:comment)) }
      it { should be_able_to(:destroy, create(:comment)) }
    end
  end
end
