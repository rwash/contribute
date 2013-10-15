class UserAction < ActiveRecord::Base
  attr_accessible :event, :message, :object_id, :object_type, :user_id
end
