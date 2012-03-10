require 'net/http'
require 'amazon/fps/base_fps_request'

module Amazon
module FPS

class PayRequest < BaseFpsRequest
  def send(caller_reference, multi_use_token, recipient_token, amount)
		params = get_default_parameters()

		params["Action"] = "Pay"
    params["CallerReference"] = caller_reference unless caller_reference.nil?
		params["RecipientTokenId"] = recipient_token
		params["SenderTokenId"] = multi_use_token
		params["TransactionAmount.Value"] = amount
		params["TransactionAmount.CurrencyCode"] = "USD"

		uri = URI.parse(@service_end_point)
    signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => params, 
                                            :aws_secret_key => @secret_key,
                                            :host => uri.host,
                                            :verb => @http_method,
                                            :uri  => uri.path })
    params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature

		return self.class.get(@service_end_point, :query => params)
	end
end

end
end
