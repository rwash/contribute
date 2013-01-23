require 'spec_helper'

describe Comment do
  # Properties
  describe 'body' do
    it 'is required' do
      comment = FactoryGirl.build(:comment, body: '')
      expect(comment.save).to be_false
    end
  end

  describe 'project' do
    it 'id is required' do
      comment = FactoryGirl.build(:comment, commentable_id: '')
      expect(comment.save).to be_false
    end
  end

  describe 'user' do
    it 'id is required' do
      comment = FactoryGirl.build(:comment, user_id: '')
      expect(comment.save).to be_false
    end
  end
=begin
  describe 'delete' do
    it 'will replace with DELETED if comment has children' do
      comment = FactoryGirl.build(:comment)
      comment.save
      comment2 = FactoryGirl.build(:comment)
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
end
