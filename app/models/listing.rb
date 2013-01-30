# === Attributes
#
# * *project_id* (+integer+)
# * *list_id* (+integer+)
# * *position* (+integer+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
class Listing < ActiveRecord::Base
  belongs_to :list
  acts_as_list scope: :list

  belongs_to :project, polymorphic: true
  paginates_per 8
end
