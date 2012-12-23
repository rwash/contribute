# === Attributes
#
# * *short_description* (+string+)
# * *long_description* (+text+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
class Category < ActiveRecord::Base
	belongs_to :project

	validates :short_description, :uniqueness => { :case_sensitive => false }

	attr_accessible :short_description, :long_description
end
