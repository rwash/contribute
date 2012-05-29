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
      comment = FacotryGirl.build(:comment, :user_id => '')
      assert !comment.save, 'Incorrectly saved comment without user id'
    end
  end

  # Methods
  # its a gem so unless we add anything i think were ok  
end
