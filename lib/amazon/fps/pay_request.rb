require 'amazon/fps/base_fps_request'
require 'amazon/fps/amazon_logger'

module Amazon
module FPS

class PayRequest < BaseFpsRequest
  def initialize(multi_use_token, recipient_token, amount)
		super()

		@params["Action"] = "Pay"
		@params["RecipientTokenId"] = recipient_token
		@params["SenderTokenId"] = multi_use_token
		@params["TransactionAmount.Value"] = amount
		@params["TransactionAmount.CurrencyCode"] = "USD"
	end

	def log_request(params)
		AmazonLogger::log_pay_request(params)
	end

	def log_response(response, request)
		AmazonLogger::log_pay_response(response, request)
	end
end

end
end
