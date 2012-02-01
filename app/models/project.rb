class Project < ActiveRecord::Base
	has_one :category
	has_attached_file :picture, :styles => {:show => "200x200>", :thumb => "100x100>"}

	#Validation constants
	def self.MAX_NAME_LENGTH; 75; end
	def self.MAX_SHORT_DESC_LENGTH; 200; end
	def self.MAX_LONG_DESC_LENGTH; 1000; end
	def self.MIN_FUNDING_GOAL; 5; end

	#Validation implementation
	validates :name, :presence => true, :uniqueness => true, :length => {:maximum => Project.MAX_NAME_LENGTH}
	validates :shortDescription, :presence => true, :length => {:maximum => Project.MAX_SHORT_DESC_LENGTH}
	validates :longDescription, :presence => true, :length => {:maximum => Project.MAX_LONG_DESC_LENGTH}

	validates :fundingGoal, :presence => true, :numericality => { :greater_than_or_equal_to => Project.MIN_FUNDING_GOAL } 
	validates :created_at, :presence => true
	validates :active, :presence => true

	validates :endDate, :presence => true

	def endDate=(endDate)
		super(Timeliness.parse(endDate, :format => 'mm/dd/yy'))
	end

	def initialize(attributes = nil, options = {})
		super
		self.active = true
		self.created_at = Date.today
	end
end
