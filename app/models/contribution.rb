class Contribution < ActiveRecord::Base
	belongs_to :project
	belongs_to :user

	validate :project_id, :presence => :true

	attr_accessible :project_id, :user_id, :amount, :payment_key

	def initialize(attributes = nil, options = {})
		super
		self.complete = false	
	end
end
