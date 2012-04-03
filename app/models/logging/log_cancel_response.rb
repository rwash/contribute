class Logging::LogCancelResponse < ActiveRecord::Base
	has_one :log_cancel_request
end
