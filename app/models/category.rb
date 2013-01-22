# === Attributes
#
# * *short_description* (+string+)
# * *long_description* (+text+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
class Category < ActiveRecord::Base
  has_many :projects

  validates :short_description, :uniqueness => { :case_sensitive => false }

  attr_accessible :short_description, :long_description
end
