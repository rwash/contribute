class AmazonPaymentAccount < ActiveRecord::Base
  belongs_to :project

  validates :project, presence: true
  validates :project_id, uniqueness: true
  validates :token, presence: true
end
