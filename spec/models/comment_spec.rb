require 'spec_helper'

describe Comment do
  describe 'valid case' do
    before(:all) do
      @comment = FactoryGirl.create(:comment)
    end
    
    after(:all) do
      @comment.delete
    end
  end
  # Properties
  describe 'body' do
    it 'is required' do
      comment = FactoryGirl.build(:comment, :body => '')
      assert !comment.save, 'Incorrectly saved comment with blank body'
    end
  end
  
  describe 'project' do
    it 'id is required' do
      comment = FactoryGirl.build(:comment, :commentable_id => '')
      assert !comment.save, 'Incorrectly save comment without proejct id'
    end
  end
  
  describe 'user' do
    it 'id is required' do
      comment = FactoryGirl.build(:comment, :user_id => '')
      assert !comment.save, 'Incorrectly saved comment without user id'
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
      assert comment.has_children?, 'comment2 did not become a child of comment.'
      comment2.delete
      assert comment2 != nil, 'Incorrectly deleted comment even though it had children.'
      assert comment2.body == "DELETED", 'comment body was not replaced with DELETED.'
    end
  end
=end
  # Methods
  # its a gem so unless we add anything i think were ok  
end
