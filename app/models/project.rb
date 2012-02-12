class Project < ActiveRecord::Base
	has_one :category

	#owner relationship
	belongs_to :user

	#contributor relationship
	#has_many :contributors

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
	validates_attachment_size :picture, :less_than => 150000, :message => "cannot be larger than 150KB"

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
		elsif end_date < Date.today + 1
			errors.add(:end_date, "has to be in the future")
		end
	end

	#Overriding to_param makes it so that whenever a url is built for a project, it substitues
	#the name of the project instead of the id of the project. This way, we can still refer
	#to params[:id] but it's actually the name. We didn't change the param to :name because
	#it was much more code that would be more error prone
	def to_param
		self.name
	end
end
