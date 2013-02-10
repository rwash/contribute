# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_listing, class: 'ProjectListing' do
    project
    list { create :project_list }
  end
end
