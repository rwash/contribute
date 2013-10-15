class UserAction < ActiveRecord::Base
  attr_accessible :event, :message, :subject_id, :subject_type, :user_id
  attr_accessible :user, :subject

  belongs_to :subject, polymorphic: true
  belongs_to :user
end
