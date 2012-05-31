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
			assert !update.save, 'Incorrectly saved update with blank title'
		end
	end

	describe 'content' do
		it 'is required' do
			update = FactoryGirl.build(:update, :content => '')
			assert !update.save, 'Incorrectly saved update with blank content'
		end
	end

	describe 'user_id' do
		it 'is required' do
			update = FactoryGirl.build(:update, :user_id => '')
			assert !update.save, 'Incorrectly saved update with no user_id'
		end
	end

	describe 'project_id' do
		it "is required" do
	      update = FactoryGirl.build(:update, :project_id => "")
	      assert !update.save, "Incorrectly saved update with no project_id"
	    end
	end

#End Properties

#Begin Methods	
#End Methods
end
