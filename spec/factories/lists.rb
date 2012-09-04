# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :list do
		listable_id 1
		listable_type "Group"
		title "Test List Title"
	end
end