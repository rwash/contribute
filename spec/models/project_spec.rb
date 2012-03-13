require 'spec_helper'

describe Project do
	describe 'end date' do
		it 'succeeds with properly formatted date' do
			project = FactoryGirl.build(:project, :end_date => '03/12/2020')
			assert project.save, 'Failed to save project with proper date'
			assert_equal project.end_date.month, 3 
			assert_equal project.end_date.day, 12 
			assert_equal project.end_date.year, 2020
		end
		it 'fails with improperly formatted date' do
			project = FactoryGirl.build(:project, :end_date => '03-12-2020')
			assert !project.save, 'Incorrectly saved project with improperly formatted date'
		end	

		it 'succeeds when equal to tomorrow' do
			project = FactoryGirl.build(:project, :end_date => Date.today + 1)
			assert project.save, 'Failed to save project with date of tomorrow'
		end
		it 'fails when equal to today' do
			project = FactoryGirl.build(:project, :end_date => Date.today)
			assert !project.save, 'Incorrectly saved project with date of today'
		end
	end

	describe 'funding goal' do
		it 'succeeds with number that does not contain commas' do
			project = FactoryGirl.build(:project, :funding_goal => 5000)
			assert project.save, 'Failed to save project with valid goal'
			assert_equal project.funding_goal, 5000
		end
		it 'succeeds with number that does contain commas' do
			project = FactoryGirl.build(:project, :funding_goal => "5,000,000")
			assert project.save, 'Failed to save project with valid goal containing commas'
			assert_equal project.funding_goal, 5000000
		end
	end

	describe 'user' do
		it 'id is required' do
			project = FactoryGirl.build(:project, :user_id => '')
			assert !project.save, 'Incorrectly saved project without user id'
		end
	end

	describe 'payment account id' do
		it 'is required' do
			project = FactoryGirl.build(:project, :payment_account_id => '')
			assert !project.save, 'Incorrectly saved project without payment account id'
		end
	end
end
