class Logging::LogGetTransactionResponse < ActiveRecord::Base
	has_one :log_get_transaction_request
end
