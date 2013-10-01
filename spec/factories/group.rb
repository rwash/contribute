# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "Test Group #{n}" }
    description "This is a group."
    owner

    open true
  end
end
