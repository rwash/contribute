require 'uri'
require 'amazon/fps/signatureutils'
require 'amazon/fps/amazon_helper'
require 'amazon/fps/base_cbui_request'

module Amazon
module FPS

class MultiTokenRequest < BaseCbuiRequest
	def url(return_url, recipient_token, amount, payment_reason)
			#Called from base class
			params = get_default_params()

			#Add in specific request parameters
			params["recipientTokenList"] = recipient_token
			#params["transactionAmount"] = amount #required if you have an amount type
			#params["amountType"] = "Exact" #this is the default
			params["globalAmountLimit"] = amount
			params["pipelineName"] = "MultiUse"
			params["returnUrl"] = "http://#{return_url}"
			params["paymentReason"] = payment_reason unless payment_reason.nil?

			#Compute signature
			uri = URI.parse(@service_end_point)
			signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => params, 
																							:aws_secret_key => @secret_key,
																							:host => uri.host,
																							:verb => @http_method,
																							:uri  => uri.path })
			params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature

			return AmazonHelper::get_url(@service_end_point, params)
	end
end

end
end
