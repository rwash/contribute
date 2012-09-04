# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :group do
		name "Test Group"
		description "This is a group."
		admin_user_id 1
	end
	factory :group2 do
		name "Test Group 2"
		description "This is a group."
		admin_user_id 2
	end
end