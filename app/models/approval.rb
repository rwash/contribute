# === Attributes
#
# * *group_id* (+integer+)
# * *project_id* (+integer+)
# * *status* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *reason* (+string+)
class Approval < ActiveRecord::Base
  belongs_to :group
  belongs_to :project

  validates_presence_of :project
  validates_presence_of :group
  validates_presence_of :status

  classy_enum_attr :status, enum: 'ApprovalStatus', default: :pending
end
