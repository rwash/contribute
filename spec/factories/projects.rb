# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
		sequence(:name) { |n| "Test Project #{n}" }
		sequence(:short_description) { |n| "This is test project #{n}" }
		sequence(:long_description) { |n| "This is project #{n}, of which the purpose is testing" }
		sequence(:end_date) { |n| Date.today + n }
		category_id 1
    # Random amount between 100 and 3000, in steps of 100
		sequence(:funding_goal) { (Random.rand(30)+1) * 100 }
		payment_account_id '636NI81VD2XQKQTN3Z566GCSMHJACXCQITC83N89SVIZSMJRDS7UUKCX2DUARGVI'
		user_id 1
    confirmed true
    state 'unconfirmed'
  end
end
