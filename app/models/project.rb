class Project < ActiveRecord::Base
	has_one :category

	#Validation constants
	def self.MAX_NAME_LENGTH; 75; end
	def self.MAX_SHORT_DESC_LENGTH; 200; end
	def self.MAX_LONG_DESC_LENGTH; 1000; end
	def self.MIN_FUNDING_GOAL; 500; end
	def self.MAX_FUNDING_GOAL; 250000; end
	#todo: dates

	#Validation implementation
	validates :name, :presence => true, :uniqueness => true, :length => {:maximum => Project.MAX_NAME_LENGTH}
	validates :shortDescription, :presence => true, :length => {:maximum => Project.MAX_SHORT_DESC_LENGTH}
	validates :longDescription, :presence => true, :length => {:maximum => Project.MAX_LONG_DESC_LENGTH}

	validates :fundingGoal, :presence => true, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality => {:greater_than_or_equal_to => Project.MIN_FUNDING_GOAL, :less_than_or_equal_to => Project.MAX_FUNDING_GOAL}
	validates :created_at, :presence => true
	validates :active, :presence => true

	validates :startDate, :presence => true
	validates :endDate, :presence => true
	validate :valid_start_end_date

	def initialize(attributes = nil, options = {})
		super
		self.active = true
		self.created_at = Date.today
	end

	def valid_start_end_date
		if !startDate || !endDate
			return
		elsif startDate < Date.today || startDate > Date.today + 1.months
			errors.add(:startDate, "must be on or within a month from today")
		elsif endDate < startDate + 1.days || endDate > startDate + 1.month
			errors.add(:endDate, "must be greater or equal to the day after the start day and less or equal to a month within the start date")
		end
	end
end
