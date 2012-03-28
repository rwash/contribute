require 'uri'
require 'amazon/fps/signatureutils'
require 'amazon/fps/amazon_helper'

module Amazon
module FPS

class BaseCbuiRequest
	def initialize
		@app_name = "CBUI"
		@http_method = "GET"
		@service_end_point = Rails.application.config.amazon_cbui_endpoint
		@cbui_version = "2009-01-09"

		@access_key = Rails.application.config.aws_access_key
		@secret_key = Rails.application.config.aws_secret_key
		@params = get_default_params()
	end

	def get_default_params()
		params = {}
		params["callerKey"] = @access_key
		params["version"] = @cbui_version
		params["callerReference"] = UUIDTools::UUID.random_create.to_s
		params[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
		params[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM
	
		return params
	end

	def url()
			uri = URI.parse(@service_end_point)
			signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => @params, 
																							:aws_secret_key => @secret_key,
																							:host => uri.host,
																							:verb => @http_method,
																							:uri  => uri.path })
			@params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature

			return AmazonHelper::get_url(@service_end_point, @params)
	end
end

end
end

