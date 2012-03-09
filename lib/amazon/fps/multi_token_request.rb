require 'uri'
require 'amazon/fps/signatureutils'

module Amazon
module FPS

class MultiTokenRequest

	#Set these values depending on the service endpoint you are going to hit
	@@app_name = "CBUI"
	@@http_method = "GET"
	@@service_end_point = "https://authorize.payments-sandbox.amazon.com/cobranded-ui/actions/start"
	@@cbui_version = "2009-01-09"

# Mitch
#	@@access_key = "AKIAJREG62RYG3LW53HA"
#	@@secret_key = "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"

# Andrew
	@@access_key = "AKIAINGLDSXXU7EG4K7Q"
	@@secret_key = "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"

	def self.get_cbui_params(amount, pipeline, caller_reference, payment_reason, host_with_port, recipient_token)
		params = {}
		params["callerKey"] = @@access_key
		params["recipientTokenList"] = recipient_token

		#params["transactionAmount"] = amount #required if you have an amount type
		params["globalAmountLimit"] = amount
		#params["amountType"] = "Exact" #this is the default

		params["pipelineName"] = pipeline
		params["returnUrl"] = "http://#{host_with_port}"
		params["version"] = @@cbui_version
		params["callerReference"] = caller_reference unless caller_reference.nil?
		params["paymentReason"] = payment_reason unless payment_reason.nil?
		params[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
		params[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM
	
		return params
	end

	def self.get_cbui_url(params)
		cbui_url = @@service_end_point + "?"

		isFirst = true
		params.each { |k,v|
			if(isFirst) then
				isFirst = false
			else
				cbui_url << '&'
			end

			cbui_url << Amazon::FPS::SignatureUtils.urlencode(k)
			unless(v.nil?) then
				cbui_url << '='
				cbui_url << Amazon::FPS::SignatureUtils.urlencode(v)
			end
		}
		return cbui_url
	end

	def self.url(amount, payment_reason, host_with_port, recipient_token)
		uri = URI.parse(@@service_end_point)
		params = get_cbui_params(amount, "MultiUse", rand(9999999), payment_reason, host_with_port, recipient_token)

		signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => params, 
																						:aws_secret_key => @@secret_key,
																						:host => uri.host,
																						:verb => @@http_method,
																						:uri  => uri.path })
		params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature

		puts get_cbui_url(params)		
		return get_cbui_url(params)
	end
end

end
end
