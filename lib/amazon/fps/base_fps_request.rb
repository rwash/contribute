require 'net/http'

module Amazon
module FPS

class BaseFpsRequest
	include HTTParty
	debug_output $stdout

	def initialize
		@app_name = "FPS"
  	@http_method = "GET"
  	@service_end_point = Rails.application.config.amazon_fps_endpoint
  	@version = "2008-09-17"

		@access_key = Rails.application.config.aws_access_key
		@secret_key = Rails.application.config.aws_secret_key
	end

  def get_default_parameters()
    params = {}
    params["Version"] = @version
    params["Timestamp"] = get_formatted_timestamp()
    params["AWSAccessKeyId"] = @access_key  
		params["callerReference"] = UUIDTools::UUID.random_create
		params[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
    params[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM

    return params
  end

  def get_formatted_timestamp()
    return Time.now.iso8601.to_s
  end
end

end
end
