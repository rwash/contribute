# === Attributes
#
# * *project_id* (+integer+)
# * *list_id* (+integer+)
# * *position* (+integer+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
class ProjectListing < Listing
  belongs_to :list, class_name: 'ProjectList', foreign_key: list_id

  belongs_to :item, class_name: 'Project'
  paginates_per 8

  alias project item
end
