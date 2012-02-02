class Project < ActiveRecord::Base
	has_one :category
	#Setting whiny to false makes it not spit verbose errors out if something like identify goes wrong
	has_attached_file :picture, :styles => {:show => "200x200>", :thumb => "100x100>"}, :whiny => false

	#Validation constants
	def self.MAX_NAME_LENGTH; 75; end
	def self.MAX_SHORT_DESC_LENGTH; 200; end
	def self.MAX_LONG_DESC_LENGTH; 1000; end
	def self.MIN_FUNDING_GOAL; 5; end

	#Validation implementation
	validates :name, :presence => true, :uniqueness => true, :length => {:maximum => Project.MAX_NAME_LENGTH}
	validates :short_description, :presence => true, :length => {:maximum => Project.MAX_SHORT_DESC_LENGTH}
	validates :long_description, :presence => true, :length => {:maximum => Project.MAX_LONG_DESC_LENGTH}

	validates :funding_goal, :numericality => { :greater_than_or_equal_to => Project.MIN_FUNDING_GOAL, :message => "must be at least $5" } 
	validates :created_at, :presence => true
	validates :active, :presence => true

	validate :validate_end_date
	validates :end_date, :presence => { :message => "must be of form 'MM/DD/YYYY'" }

	validates_attachment_content_type :picture, :content_type => /^image/, :message => "must be jpg, png, or gif"

	def end_date=(val)
		write_attribute(:end_date, Timeliness.parse(val, :format => "mm/dd/yyyy"))
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
