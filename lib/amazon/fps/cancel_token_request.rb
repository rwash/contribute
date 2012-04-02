require 'amazon/fps/base_fps_request'

module Amazon
module FPS

class CancelTokenRequest < BaseFpsRequest
  def initialize(multi_use_token)
		super()

		@params["Action"] = "CancelToken"
		@params["TokenId"] = multi_use_token

		#Don't need this for this request
		@params.delete("CallerReference")
	end

	def log_request(params)
		AmazonLogger::log_cancel_request(params)
	end

	def log_response(response, request)
		AmazonLogger::log_cancel_response(response, request)
	end

	def strip_response(response)
		if !response['CancelTokenResponse'].nil?
			return response['CancelTokenResponse']
		else
			return response['Response']
		end
	end

end

end
end
