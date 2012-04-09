require 'amazon/fps/pay_request'
require 'amazon/fps/cancel_token_request'
require 'amazon/fps/amazon_validator'

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
		self.status = ContributionStatus::NONE
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
      self.status = ContributionStatus::CANCELLED
			self.retry_count = 0
			EmailManager.contribution_cancelled(self).deliver
    else
			self.status = ContributionStatus::RETRY_CANCEL
			self.retry_count = self.retry_count + 1
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
    transaction.status = result['TransactionStatus']

    if transaction.status == "Success"
      self.status = ContributionStatus::SUCCESS
			self.retry_count = 0
			EmailManager.contribution_successful(self).deliver
		elsif transaction.contributions_status == "Pending"
			self.status = ContributionStatus::PENDING
			self.retry_count = 0
		else #TODO: elsif failure with retriable error code
			self.status = ContributionStatus::RETRY_PAY
			self.retry_count = self.retry_count + 1
    end

    self.save
  end

	def destroy
		EmailManager.project_deleted_to_contributor(self).deliver
		self.cancel	
	end
end
