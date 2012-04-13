require 'spec_helper'

describe Project do
	describe 'valid case' do
		before(:all) do
			@project = FactoryGirl.create(:project)
		end

    after(:all) do
    	@project.delete
    end

		it 'active is true' do
			assert @project.active, "Project should be active"
		end
	end

	describe 'name' do
		it 'is required' do
			project = FactoryGirl.build(:project, :name => '')
			assert !project.save, 'Incorrectly saved project with blank name'
		end

		it 'validates uniqueness' do
			project = FactoryGirl.create(:project)
			project2 = FactoryGirl.build(:project2, :name => project.name)	
			assert !project2.save, 'Incorrectly saved project with duplicate name'	
		end

		it 'fails with max length + 1' do
			project = FactoryGirl.build(:project, :name => "a" * (Project::MAX_NAME_LENGTH + 1))
			assert !project.save, 'Incorrectly saved project with name too long'
		end

		it 'saves with max length' do
			project = FactoryGirl.build(:project, :name => "a" * (Project::MAX_NAME_LENGTH))
			assert project.save, 'Failed to save project with correct name length'
		end
	end

	describe 'short description' do
		it 'is required' do
			project = FactoryGirl.build(:project, :short_description => '')
			assert !project.save, 'Incorrectly saved project with blank short_description'
		end

		it 'fails with max length + 1' do
			project = FactoryGirl.build(:project, :short_description => "a" * (Project::MAX_SHORT_DESC_LENGTH + 1))
			assert !project.save, 'Incorrectly saved project with short description too long'
		end

		it 'saves with max length' do
			project = FactoryGirl.build(:project, :short_description => "a" * (Project::MAX_SHORT_DESC_LENGTH))
			assert project.save, 'Failed to save project with correct short description length'
		end
	end

	describe 'long description' do
		it 'is required' do
			project = FactoryGirl.build(:project, :long_description => '')
			assert !project.save, 'Incorrectly saved project with blank long_description'
		end

		it 'fails with max length + 1' do
			project = FactoryGirl.build(:project, :long_description => "a" * (Project::MAX_LONG_DESC_LENGTH + 1))
			assert !project.save, 'Incorrectly saved project with long description too long'
		end

		it 'saves with max length' do
			project = FactoryGirl.build(:project, :long_description => "a" * (Project::MAX_LONG_DESC_LENGTH))
			assert project.save, 'Failed to save project with correct long description length'
		end
	end

	describe 'funding goal' do
		it "is required" do
      project = FactoryGirl.build(:project, :funding_goal => "")
      assert !project.save, "Incorrectly saved project without a funding_goal"
    end
    it "fails below minimum" do
      project = FactoryGirl.build(:project, :funding_goal => (Project::MIN_FUNDING_GOAL - 1))
      assert !project.save, "Incorrectly saved project without funding_goal below minimum project"
    end
    it "takes funding_goals with commas" do
      project = FactoryGirl.build(:project, :funding_goal => '9,999,999')
      assert project.save, "Should have saved project with funding_goal with commas"
    end
    it "is an integer" do
      project = FactoryGirl.build(:project, :funding_goal => 5.5)
      assert !project.save, "Incorrectly saved project with funding_goal that's not an int"
    end
	end

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

	describe 'user' do
		it 'id is required' do
			project = FactoryGirl.build(:project, :user_id => '')
			assert !project.save, 'Incorrectly saved project without user id'
		end
	end

	describe 'category id' do
		it 'is required' do
			project = FactoryGirl.build(:project, :category_id => '')
			assert !project.save, 'Incorrectly saved project without category id'
		end
	end

	describe 'payment account id' do
		it 'is required' do
			project = FactoryGirl.build(:project, :payment_account_id => '')
			assert !project.save, 'Incorrectly saved project without payment account id'
		end
	end

	#TODO: pictures

	describe 'contributions' do
		#These are instance variables so they can be accessed outside of the before. If they're not
		# in a before, they appear to like a before(:each) by default and cause duplicate errors 
		before(:all) do
			@project = FactoryGirl.create(:project)
			@contribution = FactoryGirl.create(:contribution, :project_id => @project.id)
			@contribution2 = FactoryGirl.create(:contribution2, :project_id => @project.id)
			@contribution3 = FactoryGirl.create(:contribution3, :project_id => @project.id)
			#Since this one is cancelled it shouldn't count towards the total
			@contribution4 = FactoryGirl.create(:contribution4, :project_id => @project.id, :status => ContributionStatus::CANCELLED)
		end

   after(:all) do
			@project.delete
    	@contribution.delete
    	@contribution2.delete
    	@contribution3.delete
    	@contribution4.delete
   end

		it 'contributions_total is correct' do
			assert_equal @project.contributions_total, 650, "Contribution total was #{@project.contributions_total} but should have been 650"	
		end

		it 'contributions_percentage is correct' do
			assert_equal @project.contributions_percentage, 65, "Contribution total was #{@project.contributions_percentage} but should have been 65"	
		end

# TODO: Why don't these stubs work? Email still gets called	
#		it 'destroy cancels contributions and sets to inactive' do
#			@contribution.stub(:destroyt => true}
#			@contribution2.stub(:destroy => true}
#			@contribution3.stub(:destroy => true}
#			@contribution.should_receive(:destroy).once
#			@contribution2.should_receive(:destroy).once
#			@contribution3.should_receive(:destroy).once
#			
#			@project.destroy
#			
#			assert !@project.active
#		end
	end
#End Properties

#Begin Methods	

#End Methods
end
