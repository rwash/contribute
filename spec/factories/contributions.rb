# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contribution do
    # Generates a number between 10 and 260 for the amount.
    amount { Random.rand(250) + 10 }

    # Randomly chosen payment key - no significance to this number.
    payment_key 'asdf8qtnq209213ja8asd'

    # Create an associated project
    project
    # Create an associated user
    user

    confirmed false
    status 'none'
  end
end
