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
end

end
end
