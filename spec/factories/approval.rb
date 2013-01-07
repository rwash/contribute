# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :approval do
    # Associate a group and a project
    group
    project

    approved nil
    reason nil
  end
end
