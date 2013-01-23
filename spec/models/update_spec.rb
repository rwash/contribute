require 'spec_helper'

describe Project do
  describe 'valid case' do
    before(:all) do
      @project = FactoryGirl.create(:project)
    end

    after(:all) do
      @project.delete
    end
  end

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
