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
	validates :short_description, :presence => true, :length => {:maximum => Project.MAX_SHORT_DESC_LENGTH}
	validates :long_description, :presence => true, :length => {:maximum => Project.MAX_LONG_DESC_LENGTH}

	validates :funding_goal, :presence => true, :numericality => { :greater_than_or_equal_to => Project.MIN_FUNDING_GOAL, :message => "must be at least $5" } 
	validates :created_at, :presence => true
	validates :active, :presence => true

	validate :validate_end_date
	validates :end_date, :presence => true

	def end_date=(end_date)
		puts "SETTING END DATE"
		write_attribute(:end_date, Timeliness.parse(end_date, :format => 'mm/dd/yy'))
	end

	def initialize(attributes = nil, options = {})
		super
		self.active = true
		self.created_at = Date.today
	end

	def validate_end_date
		if !end_date
			return
		elsif end_date <= Date.today
			errors.add(:end_date, "has to be in the future")
		end
	end
end
