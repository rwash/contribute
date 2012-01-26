class Project < ActiveRecord::Base
	has_one :category

	#Validation constants
	MAX_NAME_LENGTH = 75
	MAX_SHORT_DESC_LENGTH = 200
	MAX_LONG_DESC_LENGTH = 1000
	MIN_FUNDING_GOAL = 500	
	MAX_FUNDING_GOAL = 250000
	#todo: dates

	#Validation implementation
	validates :name, :presence => true, :uniqueness => true, :length => {:maximum => MAX_NAME_LENGTH}
	validates :shortDescription, :presence => true, :length => {:maximum => MAX_SHORT_DESC_LENGTH}
	validates :longDescription, :presence => true, :length => {:maximum => MAX_LONG_DESC_LENGTH}

	validates :fundingGoal, :presence => true, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality => {:greater_than_or_equal_to => MIN_FUNDING_GOAL, :less_than_or_equal_to => MAX_FUNDING_GOAL}
	validates :created_at, :presence => true
	validates :active, :presence => true
	#todo: dates

	def initialize(attributes = nil, options = {})
		super
		self.active = true
		self.created_at = Date.today
	end
end
