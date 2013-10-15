# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "Test Project #{n}" }
    sequence(:short_description) { |n| "This is test project #{n}" }
    sequence(:long_description) { |n| "This is project #{n}, of which the purpose is testing" }
    # TODO track down bug that occurs in other time zones, when end date is tomorrow.
    sequence(:end_date) { |n| (Date.today + n + 1).to_s(:db) }
    sequence(:funding_goal) { (Random.rand(30)+1) * 100 }
    owner
    state :unconfirmed

    factory :active_project do
      association :amazon_payment_account
      state :active

      factory :searchable_project do
        after(:create) { |instance| Sunspot.index! instance }
      end
    end
  end
end
