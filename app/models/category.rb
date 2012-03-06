class Category < ActiveRecord::Base
	belongs_to :project

	attr_accessible :short_description, :long_description
end
