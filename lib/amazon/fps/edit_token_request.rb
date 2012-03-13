require 'uri'
require 'amazon/fps/signatureutils'
require 'amazon/fps/amazon_helper'
require 'amazon/fps/base_cbui_request'

module Amazon
module FPS

class EditTokenRequest < BaseCbuiRequest
	def url(return_url, multi_token)
			super()

			#Add in specific request parameters
			@params["tokenID"] = multi_token
			@params["pipelineName"] = "EditToken"
			@params["returnUrl"] = "https:#{return_url}"
	end
end

end
end
