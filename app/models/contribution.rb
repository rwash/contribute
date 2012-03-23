MIN_CONTRIBUTION_AMT = 1
UNDEFINED_PAYMENT_KEY = 'TEMP'

class Contribution < ActiveRecord::Base
	belongs_to :project
	belongs_to :user

	validates :payment_key, :presence => true
	validates_numericality_of :amount, :greater_than_or_equal_to => MIN_CONTRIBUTION_AMT, :message => "must be at least $1"
	validates_numericality_of :amount, :only_integer => true, :message => "must be a whole dollar amount (no cents please)" 
	validates :project_id, :presence => :true
	validates :user_id, :presence => :true

	attr_accessible :project_id, :user_id, :amount, :payment_key

	def initialize(attributes = nil, options = {})
		super
		self.complete = false	
		self.cancelled = false
		self.waiting_cancellation = false
	end

  def amount=(val)
    write_attribute(:amount, val.to_s.gsub(/,/, ''))
  end
end
