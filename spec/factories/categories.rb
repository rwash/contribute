# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do
    sequence(:short_description) { |n| "Category #{n}" }
    long_description "This is a test category"
  end
end
