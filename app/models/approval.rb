class Approval < ActiveRecord::Base
	has_one :group
	has_one :project
end