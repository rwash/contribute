# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
		sequence(:name) { |n| "Test Project #{n}" }
		sequence(:short_description) { |n| "This is test project #{n}" }
		sequence(:long_description) { |n| "This is project #{n}, of which the purpose is testing" }
		sequence(:end_date) { |n| Date.today + n }
		category_id 1
		funding_goal 1000
		payment_account_id '636NI81VD2XQKQTN3Z566GCSMHJACXCQITC83N89SVIZSMJRDS7UUKCX2DUARGVI'
		user_id 1
    confirmed true
    state 'unconfirmed'
  end

  factory :project2, parent: :project, class: Project do
		category_id 2 
		funding_goal 3000
  end

  factory :project3, class: Project do
		name 'Test Project 3'
		short_description 'This is yet another test project'
		long_description 'This is yet another project, of which the purpose is testing'
		end_date { Date.today + 4 }
		category_id 2 
		funding_goal 600
		payment_account_id '63asdrg51VD2XQKQTN3Z566GCSMHJACXCQITC83N89SVIZSMJRDS7UUKCX2DUARGVI'
		user_id 1
    confirmed true
    state 'unconfirmed'
  end

  factory :project4, class: Project do
		name 'Test Project 4'
		short_description 'This is yet, yet another test project'
		long_description 'This is yet, yet another project, of which the purpose is testing'
		end_date { Date.today + 6 }
		category_id 1 
		funding_goal 50000
		payment_account_id '63asdrg51VD2XQKQTN3Z566GCSMHJACXCQITC83N89SVIZSMJRDS7UUKCX2DUasdfeI'
		user_id 1
    confirmed true
    state 'unconfirmed'
  end
end
