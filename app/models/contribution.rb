require 'amazon/fps/get_transaction_status_request'
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

  belongs_to :project
  belongs_to :user

  validates :payment_key, presence: true
  validates :amount, { presence: true,
                       numericality: { greater_than_or_equal_to: MIN_CONTRIBUTION_AMT,
                                       only_integer: true }
  }
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
  # Updates status to one of CANCELLED, RETRY_CANCEL, or FAILURE
  def cancel
    request = Amazon::FPS::CancelTokenRequest.new(self.payment_key)
    response = request.send

    cancel_status = Amazon::FPS::AmazonValidator.get_cancel_status(response)

    if cancel_status == :success
      self.status = :cancelled
      self.retry_count = 0
      EmailManager.contribution_cancelled(self).deliver
    else
      error = Amazon::FPS::AmazonValidator.get_error(response)

      if error.retriable
        self.status = :retry_cancel
        self.retry_count = self.retry_count + 1
      else
        #If the cancel failed, it won't matter to the user. Their contribution is 
        #cancelled on our end, so it won't get executed
        EmailManager.unretriable_cancel_to_admin(error, self).deliver
        self.status = :failure
      end
    end

    self.save
  end

  # Executes a contribution payment by sending a request to Amazon services.
  # Updates status to one of SUCCESS, PENDING, CANCELLED, RETRY_PAY, or FAILURE, and sends emails appropriately.
  def execute_payment
    request = Amazon::FPS::PayRequest.new(self.payment_key, self.project.payment_account_id, self.amount)

    response = request.send 
    transaction_status = Amazon::FPS::AmazonValidator.get_pay_status(response)

    if transaction_status == :success
      self.status = :success
      self.retry_count = 0
      EmailManager.contribution_successful(self).deliver
      self.transaction_id = response['PayResult']['TransactionId']
    elsif transaction_status == :pending
      self.status = :pending
      self.retry_count = 0
      self.transaction_id = response['PayResult']['TransactionId']
    elsif transaction_status == :cancelled
      EmailManager.cancelled_payment_to_admin(self).deliver
      self.status = :cancelled
    else
      error = Amazon::FPS::AmazonValidator.get_error(response)

      if error.retriable
        self.status = :retry_pay
        self.retry_count = self.retry_count + 1
      else
        if error.email_user
          EmailManager.unretriable_payment_to_user(error, self).deliver
        end
        if error.email_admin
          EmailManager.unretriable_payment_to_admin(error, self).deliver
        end
        self.status = :failure
      end
    end

    self.save
  end

  # Assumption is that we only use this on Pay calls that are pending
  def update_status
    request = Amazon::FPS::GetTransactionStatusRequest.new(self.transaction_id)
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
