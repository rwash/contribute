require 'amazon/fps/pay_request'
require 'amazon/fps/cancel_token_request'
require 'amazon/fps/amazon_validator'

MIN_CONTRIBUTION_AMT = 1
UNDEFINED_PAYMENT_KEY = 'TEMP'

class Contribution < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	belongs_to :contribution_status

	validates :payment_key, :presence => true
	validates_numericality_of :amount, :greater_than_or_equal_to => MIN_CONTRIBUTION_AMT, :message => "must be at least $1"
	validates_numericality_of :amount, :only_integer => true, :message => "must be a whole dollar amount (no cents please)" 
	validates :project_id, :presence => :true
	validates :user_id, :presence => :true

	attr_accessible :project_id, :user_id, :amount, :payment_key

	def initialize(attributes = nil, options = {})
		super
		self.contribution_status = ContributionStatus.None
		self.retry_count = 0
	end

  def amount=(val)
    write_attribute(:amount, val.to_s.gsub(/,/, ''))
  end


  def cancel
    request = Amazon::FPS::CancelTokenRequest.new(self.payment_key)
    response = request.send

    #If it was successful, we'll mark the record as cancelled
    if !Amazon::FPS::AmazonValidator::invalid_cancel_response?(response)
      self.contribution_status = ContributionStatus.Cancelled
    #otherwise we'll mark it as pending and try again later
    else
			self.contribution_status = ContributionStatus.Retry_Cancel
			self.retry_count = self.retry_count + 1
			#TODO: Tell the user? They should get an e-mail from Amazon when it actually does get cancelled
    end

    self.save
  end


  def execute_payment
    request = Amazon::FPS::PayRequest.new(self.payment_key, self.project.payment_account_id, self.amount)

    response =  request.send()
		if Amazon::FPS::AmazonValidator::invalid_payment_response?(response)
			return false
		end

		result = response['PayResult']
    transaction_id = result['TransactionId']
    transaction.contribution_status = result['TransactionStatus']

		#TODO: Need to deal with pending case for sure
		#TODO: Email!
    if transaction.contribution_status == "Success"
      self.contribution_status = ContributionStatus.Success
      self.save
    end

		return true
  end

	def destroy
		self.cancel	
	end
end
