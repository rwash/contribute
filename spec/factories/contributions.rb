# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contribution do
		amount 100
		payment_key 'asdf8qtnq209213ja8asd'
		project_id 1
		user_id 1
		confirmed false
  end

  factory :contribution2, class: Contribution do
		amount 300
		payment_key 'asdf8qad73j39213ja8asd'
		project_id 1 
		user_id 2
		confirmed false
 end

 factory :contribution3, class: Contribution do
		amount 250
		payment_key 'poiu8qad73j39213ja8asd'
		project_id 1 
		user_id 3
		confirmed false
 end
 
 factory :contribution4, class: Contribution do
		amount 50
		payment_key 'poiu8qad8fdo9213ja8asd'
		project_id 1 
		user_id 4
		confirmed false
 end

 factory :contribution5, class: Contribution do
		amount 10
		payment_key 'asdf83hd8fdo39213ja8ad'
		project_id 1 
		user_id 5
		confirmed false
 end
end
