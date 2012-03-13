# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contribution do
		amount 100
		payment_key 'asdf8qtnq209213ja8asd'
		project_id 1
		user_id 1
  end
end
