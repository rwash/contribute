# === Attributes
#
# * *itemable_id* (+integer+)
# * *itemable_type* (+string+)
# * *list_id* (+integer+)
# * *position* (+integer+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
class Item < ActiveRecord::Base
  belongs_to :list
  acts_as_list scope: :list

  belongs_to :itemable, polymorphic: true
  paginates_per 8
end
