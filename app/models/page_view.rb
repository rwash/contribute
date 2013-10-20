class PageView < ActiveRecord::Base
  attr_accessible :action, :controller, :ip, :parameters, :user_id
end
