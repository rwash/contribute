require 'spec_helper'

describe Project do
  describe 'title' do
    it 'is required' do
      update = FactoryGirl.build(:update, :title => '')
      expect(update.save).to be_false
    end
  end

  describe 'content' do
    it 'is required' do
      update = FactoryGirl.build(:update, :content => '')
      expect(update.save).to be_false
    end
  end

  describe 'user_id' do
    it 'is required' do
      update = FactoryGirl.build(:update, :user_id => '')
      expect(update.save).to be_false
    end
  end

  describe 'project_id' do
    it "is required" do
      update = FactoryGirl.build(:update, :project_id => "")
      expect(update.save).to be_false
    end
  end
end
