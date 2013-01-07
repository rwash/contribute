# Generates a repeating segment of Lorem Ipsum text, of a specified length
def lorem(length = 50)
  lorem_ipsum = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  if length > lorem_ipsum.length
    lorem_ipsum *= (length / lorem_ipsum.size)
  end
  lorem_ipsum[0..length]
end

FactoryGirl.define do
  factory :comment do
    body lorem(Random.rand(100) + 50)
    association :user
  end
end
