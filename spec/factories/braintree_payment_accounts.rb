require 'securerandom'

FactoryGirl.define do
  factory :braintree_payment_account do
    token { SecureRandom.hex }
    project
  end
end
