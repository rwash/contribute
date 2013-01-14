# === Attributes
#
# * *group_id* (+integer+)
# * *project_id* (+integer+)
# * *approved* (+boolean+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *reason* (+string+)
class Approval < ActiveRecord::Base
  belongs_to :group
  belongs_to :project
end
