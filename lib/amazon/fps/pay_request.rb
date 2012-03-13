require 'net/http'
require 'amazon/fps/base_fps_request'

module Amazon
module FPS

class PayRequest < BaseFpsRequest
  def initialize(multi_use_token, recipient_token, amount)
		super()

		@params["Action"] = "Pay"
		@params["RecipientTokenId"] = recipient_token
		@params["SenderTokenId"] = multi_use_token
		@params["TransactionAmount.Value"] = amount
		@params["TransactionAmount.CurrencyCode"] = "USD"
	end
end

end
end
