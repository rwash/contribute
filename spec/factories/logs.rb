# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  # Define a bunch of empty factories for the logging system...
  factory :log_cancel_request do end
  factory :log_cancel_response do end
  factory :log_error do end
  factory :log_get_transaction_request do end
  factory :log_get_transaction_response do end
  factory :log_multi_token_request do end
  factory :log_multi_token_response do end
  factory :log_pay_request do end
  factory :log_pay_response do end
  factory :log_recipient_token_response do end
end
