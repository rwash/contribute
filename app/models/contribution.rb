require 'amazon/fps/pay_request'
require 'amazon/fps/cancel_token_request'

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


  def cancel
    request = Amazon::FPS::CancelTokenRequest.new(self.payment_key)
    response = request.send

    #If it was successful, we'll mark the record as cancelled
    if response["Errors"].nil? #TODO: Is this a good enough error check?
			self.waiting_cancellation = 0
      self.cancelled = 1
    #otherwise we'll mark it as pending and try again later
    else
      self.waiting_cancellation = self.waiting_cancellation + 1
			#TODO: Tell the user? They should get an e-mail from Amazon when it actually does get cancelled
    end

    self.save
  end


  def execute_payment
    request = Amazon::FPS::PayRequest.new(self.payment_key, self.project.payment_account_id, self.amount)

    response =  request.send()

    result = response['PayResponse']['PayResult']
    transaction_id = result['TransactionId']
    transaction_status = result['TransactionStatus']

		#TODO: Need to deal with pending case for sure
    if transaction_status == "Success"
      self.complete = true
      self.save
    end
  end

end
