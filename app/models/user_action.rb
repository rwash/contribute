class UserAction < ActiveRecord::Base
  attr_accessible :event, :message, :subject_id, :subject_type, :user_id

  belongs_to :subject, polymorphic: true
end
