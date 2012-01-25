class Project < ActiveRecord::Base
	has_one :category

	def initialize
		super
		self.active = true
	end
end
