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

  describe 'body' do
    it 'is required' do
      comment = FactoryGirl.build(:comment, :body => '')
      asser !comment.save, 'Incorrectly saved comment with blank body'
    end
  end
    
end
