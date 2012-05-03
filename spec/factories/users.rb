# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email 'test@test.com'
		name 'Test Guy'
		password 'testme'
  end

  factory :user2, class: User do
    email 'test2@test.com'
		name 'Test Guy 2'
		password 'testme'
  end
end
