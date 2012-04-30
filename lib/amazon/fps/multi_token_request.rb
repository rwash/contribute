require 'amazon/fps/base_cbui_request'
require 'amazon/fps/amazon_logger'

module Amazon
module FPS

class MultiTokenRequest < BaseCbuiRequest

	#multi-token action specific parameters are filled in, logs the request
	def initialize(session, return_url, recipient_token, amount, payment_reason)
			super()

			#Add in specific request parameters
			@params["recipientTokenList"] = recipient_token
			#params["transactionAmount"] = amount #required if you have an amount type
			#params["amountType"] = "Exact" #this is the default
			@params["globalAmountLimit"] = amount
			@params["pipelineName"] = "MultiUse"
			@params["returnUrl"] = return_url
			@params["paymentReason"] = payment_reason unless payment_reason.nil?

			AmazonLogger::log_multi_token_request(@params, session)
	end
end

end
end
