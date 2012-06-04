class Project < ActiveRecord::Base
	MAX_NAME_LENGTH = 75
	MAX_SHORT_DESC_LENGTH = 200
	MAX_LONG_DESC_LENGTH = 1000
	MIN_FUNDING_GOAL = 5
	UNDEFINED_PAYMENT_ACCOUNT_ID = 'TEMP'

	belongs_to :user
  has_many :contributions, :conditions => ["status not in (:retry_cancel, :fail, :cancelled)", {:retry_cancel => ContributionStatus::RETRY_CANCEL, :fail => ContributionStatus::FAILURE, :cancelled => ContributionStatus::CANCELLED}]
  acts_as_commentable

	has_many :comments
	has_many :updates
	has_one :category
	mount_uploader :picture, PictureUploader, :mount_on => :picture_file_name

	validates :name, :presence => true, :uniqueness => { :case_sensitive => false }, :length => {:maximum => MAX_NAME_LENGTH}
	validates :short_description, :presence => true, :length => {:maximum => MAX_SHORT_DESC_LENGTH}
	validates :long_description, :presence => true, :length => {:maximum => MAX_LONG_DESC_LENGTH}
	validates_numericality_of :funding_goal, :greater_than_or_equal_to => MIN_FUNDING_GOAL, :message => "must be at least $5"
	validates_numericality_of :funding_goal, :only_integer => true, :message => "must be a whole dollar amount (no cents please)"
	validate :validate_end_date
	validates :end_date, :presence => { :message => "must be of form 'MM/DD/YYYY'" }
	validates :payment_account_id, :presence => true
	validates :category_id, :presence => true
	validates :user_id, :presence => true

	attr_accessible :name, :short_description, :long_description, :funding_goal, :end_date, :category_id, :picture, :picture_cache
	
	def initialize(attributes = nil, options = {})
		super
		# self.active = true # We dont want to use this anymore.
		# self.confirmed = false # We dont want to use this anymore.
	end

	def end_date=(val)
		write_attribute(:end_date, Timeliness.parse(val, :format => "mm/dd/yyyy"))
	end
	
	def funding_goal=(val)  
		write_attribute(:funding_goal, val.to_s.gsub(/,/, ''))
	end

	def validate_end_date
		if !end_date
			return
		elsif end_date < Date.today + 1
			errors.add(:end_date, "has to be in the future")
		end
	end

	def contributions_total
		Rails.cache.fetch("#{self.id}_contributions_total") do 
			contributions.sum(:amount)
		end
	end

	def contributions_percentage
		Rails.cache.fetch("#{self.id}_contributions_percentage") do 
			((contributions_total.to_f / funding_goal.to_f) * 100).to_i
		end
	end

	#Overriding to_param makes it so that whenever a url is built for a project, it substitues
	#the name of the project instead of the id of the project. This way, we can still refer
	#to params[:id] but it's actually the name. We didn't change the param to :name because
	#it was much more code that would be more error prone
	def to_param
		self.name
	end

	def destroy
		EmailManager.project_deleted_to_owner(self).deliver	

    self.contributions.each do |contribution|
			EmailManager.project_deleted_to_contributor(contribution).deliver
      contribution.destroy
    end

    # self.active = false # We dont want to use this anymore.
    self.save
	end

	def active?
		self.state == PROJ_STATES[2] #active
	end
	
	def public_can_view? #active, funded, or non-funded
  	self.state == PROJ_STATES[2] || self.state == PROJ_STATES[3] || self.state == PROJ_STATES[4]
  end
  
  def can_edit? #unconfirmed or inactive
  	self.state == PROJ_STATES[0] || self.state == PROJ_STATES[1]
  end
  
  def can_update? #active, funded or non-funded AND current user is project owner
  	self.state == PROJ_STATES[2] || self.state == PROJ_STATES[3] || self.state == PROJ_STATES[4]
  end
  
  def can_comment? #active, funded, or non-funded
  	self.state == PROJ_STATES[2] || self.state == PROJ_STATES[3] || self.state == PROJ_STATES[4]
  end
  
  def unconfirmed?
  	self.state == PROJ_STATES[0]
  end
end
