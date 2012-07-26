# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :approval do
		group_id 1
		project_id 1
		approved nil
		reason nil
	end
end