class Logging::LogCancelResponse < ActiveRecord::Base
	has_one :long_cancel_request
end
