# === Attributes
#
# * *log_cancel_request_id* (+integer+)
# * *RequestId* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
class Logging::LogCancelResponse < ActiveRecord::Base
	has_one :log_cancel_request
end
