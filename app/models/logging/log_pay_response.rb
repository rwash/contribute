# === Attributes
#
# * *TransactionId* (+string+)
# * *TransactionStatus* (+string+)
# * *RequestId* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *log_pay_request_id* (+integer+)
class Logging::LogPayResponse < ActiveRecord::Base
	belongs_to :log_pay_request
end
