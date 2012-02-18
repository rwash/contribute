# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email 'test@test.com'
		name 'Test Guy'
		password 'testme'
  end
end
