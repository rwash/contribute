require 'amazon/fps/get_transaction_status_request'
require 'amazon/fps/cancel_token_request'
require 'amazon/fps/amazon_validator'
require 'amazon/fps/pay_request'

class Contribution < ActiveRecord::Base
	MIN_CONTRIBUTION_AMT = 1
	UNDEFINED_PAYMENT_KEY = 'TEMP'

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

		cancel_status = Amazon::FPS::AmazonValidator.get_cancel_status(response)

    if cancel_status == ContributionStatus::SUCCESS
      self.status = ContributionStatus::CANCELLED
			self.retry_count = 0
			EmailManager.contribution_cancelled(self).deliver
    else
			error = Amazon::FPS::AmazonValidator.get_error(response)

			if error.retriable
				self.status = ContributionStatus::RETRY_CANCEL
				self.retry_count = self.retry_count + 1
			else
				if error.email_admin
					#Notify the admin - this would be a rare case (and most likely our fault)
					EmailManager.unretriable_cancel_admin(error, self)
				end
				self.status = ContributionStatus::FAILURE
			end
    end

    self.save
  end

  def execute_payment
    request = Amazon::FPS::PayRequest.new(self.payment_key, self.project.payment_account_id, self.amount)

		response = request.send 
		transaction_status = Amazon::FPS::AmazonValidator.get_pay_status(response)

		if transaction_status == ContributionStatus::SUCCESS
      self.status = ContributionStatus::SUCCESS
			self.retry_count = 0
			EmailManager.contribution_successful(self).deliver

			self.transaction_id = response['PayResult']['TransactionId'] unless response['PayResult'].nil?
		elsif transaction_status == ContributionStatus::PENDING
			self.status = ContributionStatus::PENDING
			self.retry_count = 0
			self.transaction_id = response['PayResult']['TransactionId'] unless response['PayResult'].nil?
		elsif transaction_status == ContributionStatus::CANCELLED
			#TODO: Who do you e-mail? User could've cancelled or something could've gone wrong... update: will this case ever happen?
			self.status = ContributionStatus::CANCELLED
		else
			error = Amazon::FPS::AmazonValidator.get_error(response)

			if error.retriable
				self.status = ContributionStatus::RETRY_PAY
				self.retry_count = self.retry_count + 1
			else
				if error.email_user
					EmailManager.redo_contribution(error, self)
				end
				if error.email_admin
					EmailManager.unretriable_contribution_admin(error, self)
				end
				self.status = ContributionStatus::FAILURE
			end
    end

    self.save
  end

	# Assumption is that we only use this on Pay calls that are pending
	def update_status
		request = Amazon::FPS::GetTransactionStatusRequest.new(self.transaction_id)
		response = request.send
		
		if !Amazon::FPS::AmazonValidator::valid_transaction_status_response?(response)
			error = Amazon::FPS::AmazonValidator::get_error(response)
			EmailManager.update_contribution_admin(error, self)
			return
		end

		transaction_status = Amazon::FPS::AmazonValidator::get_transaction_status(response)
		if transaction_status == ContributionStatus::SUCCESS
			EmailManager.contribution_successful(self).deliver
			self.retry_count = 0
			self.status = ContributionStatus::SUCCESS
		elsif transaction_status = ContributionStatus::FAILURE
			EmailManager.redo_pending_contribution(self)
			self.retry_count = 0
			self.status = ContributionStatus::FAILURE
		elsif transaction_status = ContributionStatus::CANCELLED
			#TODO: Who do you e-mail? User could've cancelled or something could've gone wrong... update: again, should we even worry about this?
			self.retry_count = 0
			self.status = ContributionStatus::CANCELLED
		elsif transaction_status = ContributionStatus::PENDING
			self.retry_count = self.retry_count + 1
		end

		self.save	
	end

	def destroy
		EmailManager.project_deleted_to_contributor(self).deliver
		self.cancel	
	end
end
