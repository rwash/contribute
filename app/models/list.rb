# === Attributes
#
# * *kind* (+string+)
# * *listable_id* (+integer+)
# * *listable_type* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *title* (+string+)
# * *show_active* (+boolean+)
# * *show_funded* (+boolean+)
# * *show_nonfunded* (+boolean+)
# * *permanent* (+boolean+)
class List < ActiveRecord::Base
  LIST_KINDS = %w[default manual created-at-descending created-at-ascending end-date-descending end-date-ascending funding-goal-descending funding-goal-ascending amount-left-to-goal-in-dollars-descending amount-left-to-goal-in-dollars-ascending amount-left-to-goal-as-percent-descending amount-left-to-goal-as-percent-ascending amount-donated-in-dollars-descending amount-donated-in-dollars-ascending amount-donated-as-percent-of-goal-descending amount-donated-as-percent-of-goal-ascending random-descending random-ascending]

  has_many :items, :order => "position"
  belongs_to :listable, :polymorphic => true
  validate :validate_kind

  validates :listable_id, :presence => true
  validates :listable_type, :presence => true

  def validate_kind
    errors.add(:kind, "Invalid value for kind, check list.rb") unless LIST_KINDS.include?(self.kind)
  end
end
