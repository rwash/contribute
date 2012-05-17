class Comment < ActiveRecord::Base

  belongs_to :user
  belongs_to :project
  belongs_to :parent, :class_name => 'Comment'
  has_many :children, :class_name => 'Comment'
  
  validates :content, :presence => true
  validates :userid, :presence => true
  
  attr_accessible :content, :user_id
  
  
end