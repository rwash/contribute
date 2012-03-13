MIN_CONTRIBUTION_AMT = 1

class Contribution < ActiveRecord::Base
	belongs_to :project
	belongs_to :user

	validates :payment_key, :presence => true
	validates :amount, :presence => :true, :numericality => { :greater_than_or_equal_to => MIN_CONTRIBUTION_AMT, :message => "must be at least $1" }
	validates :project_id, :presence => :true

	attr_accessible :project_id, :user_id, :amount, :payment_key

	def initialize(attributes = nil, options = {})
		super
		self.complete = false	
	end
end
