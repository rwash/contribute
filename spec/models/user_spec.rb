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
			assert_not_nil @user
		end
	end

	describe 'name' do
		it 'is required' do
			user = FactoryGirl.build(:user, :name => '')
			assert !user.save, "Incorrectly saved user with blank name"
		end
	end
end
