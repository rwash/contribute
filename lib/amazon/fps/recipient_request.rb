require 'uri'
require 'amazon/fps/signatureutils'
require 'amazon/fps/amazon_helper'
require 'amazon/fps/base_cbui_request'

module Amazon
module FPS

class RecipientRequest < BaseCbuiRequest
	def url(return_url, caller_reference)
		#Called from base class
		params = get_default_params()

		#Add in specific request parameters
		params["recipientPaysFee"] = true #what should we set this to?
		params["pipelineName"] = "Recipient"
		params["returnUrl"] = "http://#{return_url}"
		params["callerReference"] = caller_reference unless caller_reference.nil?

		#Compute signature
		puts 'serviceendpoint', @service_end_point
		uri = URI.parse(@service_end_point)
		signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => params, 
																						:aws_secret_key => @secret_key,
																						:host => uri.host,
																						:verb => @http_method,
																						:uri  => uri.path })
		params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature
		
		#return url
		return AmazonHelper::get_url(@service_end_point, params)
	end
end

end
end
