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
	end

	def get_default_params()
		params = {}
		params["callerKey"] = @access_key
		params["version"] = @cbui_version
		params[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
		params[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM
	
		return params
	end
end

end
end

