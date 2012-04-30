require 'amazon/fps/base_fps_request'
require 'amazon/fps/amazon_logger'

module Amazon
module FPS

#Performs the actually payment between a multi-token and recipient token
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

	#If an error returns, the beginning element will be 'Response' rather than 'PayResonse'.  Amazon is a royal pain in the ass.  This applies to all other fps strip_response calls as well.
	def strip_response(response)
		if !response['PayResponse'].nil? #When we convert from xml, the actual response parameters are within the keys 'Response' or 'PayResponse'
			response = response['PayResponse']
		else
			response = response['Response']
		end
	end
end

end
end
