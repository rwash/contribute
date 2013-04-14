require 'spec_helper'

describe Approval do
  # Abilities
  describe 'Abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:ability) { build_stubbed :group }

    context 'when not signed in' do
      let(:user) { nil }
      # TODO
    end

    context 'when signed in' do
      let(:user) { create :user }
      # TODO
    end

    context 'when user owns group' do
      let(:user) { group.admin_user }
      # TODO
    end

    context 'when signed in as admin' do
      let(:user) { create :user, admin: true }
      # TODO
    end
  end

  it { should validate_presence_of :group }
  it { should validate_presence_of :project }
  it { should validate_presence_of :status }
  it { should ensure_inclusion_of(:status).in_array [:pending, :approved, :rejected] }

end
