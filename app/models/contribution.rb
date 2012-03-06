class Contribution < ActiveRecord::Base
	belongs_to :project
	belongs_to :user

	def initialize(attributes = nil, options = {})
		super
		self.complete = false	
	end
end
