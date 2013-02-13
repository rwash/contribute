# Enables users to comment on a Project or other 'commentable' models.
#
# === Attributes
#
# * *commentable_id* (+integer+)
# * *commentable_type* (+string+)
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
  acts_as_nested_set scope: [:commentable_id, :commentable_type]

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates_presence_of :body
  validates_presence_of :user
  validates_presence_of :commentable_id

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end
end
