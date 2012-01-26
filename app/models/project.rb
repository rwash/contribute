class Project < ActiveRecord::Base
	has_one :category

	def initialize(attributes = nil, options = {})
		super
		self.active = true
	end
end
