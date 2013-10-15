require 'uri'
require 'amazon/fps/base_cbui_request'

module Amazon
module FPS

class RecipientRequest < BaseCbuiRequest

	#there are only a couple recipient-token specific parameters needed, so we are not bothering to log the request	
	def initialize(return_url)
		super()

		@params["recipientPaysFee"] = true
		@params["pipelineName"] = "Recipient"
		@params["returnUrl"] = return_url
	end
end

end
end
