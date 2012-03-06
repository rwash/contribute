class Category < ActiveRecord::Base
	belongs_to :project

	validates :short_description, :uniqueness => { :case_sensitive => false }

	attr_accessible :short_description, :long_description
end
