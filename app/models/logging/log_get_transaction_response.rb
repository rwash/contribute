# === Attributes
#
# * *TransactionId* (+string+)
# * *TransactionStatus* (+string+)
# * *CallerReference* (+string+)
# * *StatusCode* (+string+)
# * *StatusMessage* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *log_get_transaction_request_id* (+integer+)
# * *RequestId* (+string+)
class Logging::LogGetTransactionResponse < ActiveRecord::Base
	has_one :log_get_transaction_request
end
