require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
	test "presence on all columns" do
		project = Project.new
		assert project.invalid?
		assert project.errors[:name].any?
		assert project.errors[:shortDescription].any?
		assert project.errors[:longDescription].any?
		#assert project.errors[:endDate].any?
		#assert project.errors[:startDate].any?
		assert project.errors[:fundingGoal].any?
		
		#Test these two columns have been initialized
		assert !project.errors[:created_at].any?
		assert !project.errors[:active].any?
	end

	test "uniqueness of name" do
		project = Project.new(name: projects(:goggles).name)
	
		assert !project.save
		assert_equal "has already been taken", project.errors[:name].join('; ')
	end

	test "valid funding goal" do
		project = projects(:goggles)
		assert project.valid?, "Project wasn't valid to begin with, check project fixture"
		
		project.fundingGoal = Project.MIN_FUNDING_GOAL - 1
		assert project.invalid?

		project.fundingGoal = Project.MAX_FUNDING_GOAL + 1
		assert project.invalid?

		project.fundingGoal = -1
		assert project.invalid?

		project.fundingGoal = Project.MIN_FUNDING_GOAL + 0.1234
		assert project.invalid?

		project.fundingGoal = Project.MIN_FUNDING_GOAL + 1
		assert project.valid?

		project.fundingGoal = Project.MAX_FUNDING_GOAL - 1
		assert project.valid?

		project.fundingGoal = Project.MIN_FUNDING_GOAL + 0.11
		assert project.valid?
	end
end
