FactoryGirl.define do
  factory :comment do
    body 'This is a comment. Useed for testing.'
    user_id 1
  end
  
  factory :comment2 do
    body 'This is another comment used for testing. This is is much longer and may or may not actually be usefull.'
    user_id 1 
  end
end