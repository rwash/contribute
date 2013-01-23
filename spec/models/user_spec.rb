require 'spec_helper'

describe User do
  describe 'valid case' do
    before(:all) do
      @user = FactoryGirl.create(:user)
    end

    after(:all) do
      @user.delete
    end

    it 'checks validity to make the before run :)' do
      expect(@user).to_not be_nil
    end
  end

  describe 'name' do
    it 'is required' do
      user = FactoryGirl.build(:user, :name => '')
      expect(user.save).to be_false
    end
  end
end
