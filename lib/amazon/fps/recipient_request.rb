require 'uri'
require 'amazon/fps/signatureutils'
require 'amazon/fps/base_cbui_request'

module Amazon
module FPS

class RecipientRequest < BaseCbuiRequest
	def initialize(return_url)
		super()

		#Add in specific request parameters
		@params["recipientPaysFee"] = true #what should we set this to?
		@params["pipelineName"] = "Recipient"
		@params["returnUrl"] = return_url
	end
end

end
end
