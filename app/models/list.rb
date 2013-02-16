# === Attributes
#
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
  belongs_to :listable, polymorphic: true

  validates :listable_id, presence: true
  validates :listable_type, presence: true
end
