class PaymentAccount < ActiveRecord::Base
  self.table_name = 'amazon_payment_accounts'

  belongs_to :project

  validates :project, presence: true
  validates :project_id, uniqueness: true
  validates :token, presence: true
end
