require 'amazon/fps/base_fps_request'

module Amazon
module FPS

#We use the request to see the transaction result of pending payments
class TransactionStatusRequest < BaseFpsRequest
  def initialize(payment_key)
		super()

		@params.delete("CallerReference")

		@params["Action"] = "GetTransactionStatus"
		@params["TransactionId"] = payment_key 
	end

	def strip_response(response)
		if !response['GetTransactionStatusResponse'].nil?
			response = response['GetTransactionStatusResponse']
		else
			response = response['Response']
		end
	end

	def log_request(params)
		Amazon::FPS::AmazonLogger.log_get_transaction_request(params)
	end

	def log_response(response, request)
		Amazon::FPS::AmazonLogger.log_get_transaction_response(response, request)
	end

end

end
end
