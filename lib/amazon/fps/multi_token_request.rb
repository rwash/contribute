require 'amazon/fps/base_cbui_request'

module Amazon
module FPS

class MultiTokenRequest < BaseCbuiRequest
	def initialize(return_url, recipient_token, amount, payment_reason)
			super()

			#Add in specific request parameters
			@params["recipientTokenList"] = recipient_token
			#params["transactionAmount"] = amount #required if you have an amount type
			#params["amountType"] = "Exact" #this is the default
			@params["globalAmountLimit"] = amount
			@params["pipelineName"] = "MultiUse"
			@params["returnUrl"] = return_url
			@params["paymentReason"] = payment_reason unless payment_reason.nil?
	end
end

end
end
