# === Attributes
#
# * *group_id* (+integer+)
# * *project_id* (+integer+)
# * *approved* (+boolean+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *reason* (+string+)
class Approval < ActiveRecord::Base
	has_one :group
	has_one :project
end
