# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
		name 'Test Project'
		short_description 'This is a test project'
		long_description 'This is a project, of which the purpose is testing'
		end_date { Date.today + 1 }
		category_id 1
		funding_goal 1000
		payment_account_id 'adsfq42t354yw5ysdyw5ywsdfg6sd'
		user_id 1
  end

  factory :project2, class: Project do
		name 'Test Project 2'
		short_description 'This is another test project'
		long_description 'This is another project, of which the purpose is testing'
		end_date { Date.today + 2 }
		category_id 2 
		funding_goal 3000
		payment_account_id 'adsfq42t354asdf83w5ywsdfg6sd'
		user_id 2
  end
end
