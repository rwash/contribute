# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test_#{n}@test.com" }
    sequence(:name)  { |n| "Test Guy #{n}" }
    password 'testme'
    after_build do |obj|
      obj.confirm!
    end
  end

end
