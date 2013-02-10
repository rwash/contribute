require 'spec_helper'

describe Comment do
  # Validations

  it { should validate_presence_of :body }
  it { should validate_presence_of :commentable_id }
  it { should validate_presence_of :user }

=begin
  describe 'delete' do
    it 'will replace with DELETED if comment has children' do
      comment = build(:comment)
      comment.save
      comment2 = build(:comment)
      comment2.save
      comment2.move_to_child_of(comment)
      expect(comment.children.any?).to be_true
      comment2.delete
      expect(comment2).to_not be_nil
      expect(comment2.body) to eq "DELETED"
    end
  end
=end
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
