require 'amazon/fps/transaction_status_request'
require 'amazon/fps/cancel_token_request'
require 'amazon/fps/amazon_validator'
require 'amazon/fps/pay_request'

# Keeps track of users' contributions to projects.
#
# === Attributes
#
# * *payment_key* (+string+)
# * *amount* (+integer+)
# * *project_id* (+integer+)
# * *user_id* (+integer+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *status* (+integer+)
# * *retry_count* (+integer+)
# * *transaction_id* (+string+)
# * *confirmed* (+boolean+, default: +false+)
class Contribution < ActiveRecord::Base
  MIN_CONTRIBUTION_AMT = 1
  UNDEFINED_PAYMENT_KEY = 'TEMP'
  MAX_CANCEL_RETRIES = 4

  belongs_to :project
  belongs_to :user

  validates :payment_key, presence: true
  validates_presence_of :amount
  validates_numericality_of :amount, greater_than_or_equal_to: MIN_CONTRIBUTION_AMT, message: "must be at least $1"
  validates_numericality_of :amount, only_integer: true, message: "must be a whole dollar amount (no cents please)" 
  validates :project_id, presence: :true
  validates :user_id, presence: :true

  attr_accessible :project_id, :user, :amount, :payment_key

  classy_enum_attr :status, enum: 'ContributionStatus'

  # Overwrides default setter
  # Accepts input as a string of numbers with commas.
  def amount=(val)
    write_attribute(:amount, val.to_s.gsub(/,/, ''))
  end

  # Cancels a contribution by sending a request to Amazon services.
  # Updates status to either CANCELLED or FAILURE
  def cancel
    AmazonFlexPay.cancel_token(payment_key)
    self.status = :cancelled

  rescue AmazonFlexPay::API::Error => error
    #If the cancel failed, it won't matter to the user. Their contribution is
    #cancelled on our end, so it won't get executed
    EmailManager.unretriable_cancel_to_admin(error, self).deliver
    self.status = :failure
  ensure
    EmailManager.contribution_cancelled(self).deliver
    save
  end

  # Executes a contribution payment by sending a request to Amazon services.
  # Updates status to one of SUCCESS, PENDING, CANCELLED, RETRY_PAY, or FAILURE, and sends emails appropriately.
  def execute_payment
    response = AmazonFlexPay.pay(amount, 'USD', payment_key, project.payment_account_id)
    if response.transaction_status == 'Success'
      self.status = :success
      self.retry_count = 0
      EmailManager.contribution_successful(self).deliver
      self.transaction_id = response.transaction_id
    elsif response.transaction_status == "Pending"
      self.status = :pending
      self.retry_count = 0
      self.transaction_id = response.transaction_id
    elsif response.transaction_status == "Cancelled"
      EmailManager.cancelled_payment_to_admin(self).deliver
      self.status = :cancelled
    end
  rescue AmazonFlexPay::API::Error => error
    EmailManager.unretriable_payment_to_user(error, self).deliver
    EmailManager.unretriable_payment_to_admin(error, self).deliver
    self.status = :failure
  ensure
    save
  end

  # Assumption is that we only use this on Pay calls that are pending
  def update_status
    request = Amazon::FPS::TransactionStatusRequest.new(self.transaction_id)
    response = request.send

    if !Amazon::FPS::AmazonValidator.valid_transaction_status_response?(response)
      error = Amazon::FPS::AmazonValidator.get_error(response)
      EmailManager.failed_status_to_admin(error, self).deliver
      return
    end

    transaction_status = Amazon::FPS::AmazonValidator.get_transaction_status(response)
    if transaction_status == :success
      EmailManager.contribution_successful(self).deliver
      self.retry_count = 0
      self.status = :success
    elsif transaction_status == :failure
      EmailManager.failed_payment_to_user(self).deliver
      self.status = :failure
    elsif transaction_status == :cancelled
      EmailManager.cancelled_payment_to_admin(self).deliver
      self.status = :cancelled
    elsif transaction_status == :pending
      self.retry_count = self.retry_count + 1
    end

    self.save	
  end

  # Overrides the default destroy action.
  # Cancels the contribution instead of destroying record.
  def destroy
    self.cancel	
  end
end
