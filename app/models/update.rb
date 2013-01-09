# === Attributes
#
# * *content* (+text+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *user_id* (+integer+)
# * *project_id* (+integer+)
# * *email_sent* (+boolean+)
# * *title* (+string+)
class Update < ActiveRecord::Base

  validates_presence_of :title
  validates_presence_of :content
  validates_presence_of :user_id
  validates_presence_of :project_id

  belongs_to :project
  belongs_to :user

end
