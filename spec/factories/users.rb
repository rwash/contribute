# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :unconfirmed_user, class: User do
    sequence(:email) { |n| "test_#{n}@test.com" }
    sequence(:name)  { |n| "Test Guy #{n}" }
    password 'testme'
  end

  factory :user, parent: :unconfirmed_user, aliases: [:admin_user, :owner] do
    after(:build) do |obj|
      obj.confirm!
    end
  end
end
