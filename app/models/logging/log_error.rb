# === Attributes
#
# * *log_request_id* (+integer+)
# * *Code* (+string+)
# * *Message* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *RequestId* (+string+)
class Logging::LogError < ActiveRecord::Base
	belongs_to :log_pay_request, :foreign_key => "log_request_id"
	#belongs_to :log_cancel_request, :foreign_key => "request_id"
end
