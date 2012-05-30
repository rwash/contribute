class Update < ActiveRecord::Base

  validates_presence_of :content
  validates_presence_of :user
  
  belongs_to :project
  belongs_to :user
  
end
