MAX_NAME_LENGTH = 75
MAX_SHORT_DESC_LENGTH = 200
MAX_LONG_DESC_LENGTH = 1000
MIN_FUNDING_GOAL = 5

class Project < ActiveRecord::Base
	belongs_to :user
	has_many :contributions

	has_one :category
	mount_uploader :picture, PictureUploader, :mount_on => :picture_file_name

	validates :name, :presence => true, :uniqueness => true, :length => {:maximum => MAX_NAME_LENGTH}
	validates :short_description, :presence => true, :length => {:maximum => MAX_SHORT_DESC_LENGTH}
	validates :long_description, :presence => true, :length => {:maximum => MAX_LONG_DESC_LENGTH}
	validates :funding_goal, :numericality => { :greater_than_or_equal_to => MIN_FUNDING_GOAL, :message => "must be at least $5" } 
	validates :created_at, :presence => true
	validates :active, :presence => true
	validate :validate_end_date
	validates :end_date, :presence => { :message => "must be of form 'MM/DD/YYYY'" }
	validates :picture, :file_size => {:maximum => 0.15.megabytes.to_i }
	
	def initialize(attributes = nil, options = {})
		super
		self.active = true
		self.created_at = Date.today
	end

	def end_date=(val)
		write_attribute(:end_date, Timeliness.parse(val, :format => "mm/dd/yyyy"))
	end
	
	def funding_goal=(val)  
		write_attribute(:funding_goal, val.to_s.gsub(/,/, '').to_i)
	end

	def validate_end_date
		if !end_date
			return
		elsif end_date < Date.today + 1
			errors.add(:end_date, "has to be in the future")
		end
	end

	#Currently this method only checks if the project is active
	#But this should be more extensible
	def isValid?
		if !active
			return false	
		else	
			return true
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
