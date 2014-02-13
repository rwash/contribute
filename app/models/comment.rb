# Enables users to comment on a Project
#
# === Attributes
#
# * *project_id* (+integer+)
# * *title* (+string+)
# * *body* (+text+)
# * *subject* (+string+)
# * *user_id* (+integer+)
# * *parent_id* (+integer+)
# * *lft* (+integer+)
# * *rgt* (+integer+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates_presence_of :body
  validates_presence_of :user
  validates_presence_of :project
end
