require 'net/http'

module Amazon
module FPS

class PayRequest
	include HTTParty
	debug_output $stdout

  #Set these values depending on the service endpoint you are going to hit
  @@app_name = "FPS"
  @@http_method = "GET"
  @@service_end_point = "https://fps.sandbox.amazonaws.com/"
  @@version = "2008-09-17"

	@@access_key = "AKIAJREG62RYG3LW53HA"
	@@secret_key = "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"

  def get_fps_default_parameters()
    parameters = {}
    parameters["Version"] = @@version
    parameters["Timestamp"] = get_formatted_timestamp()
    parameters["AWSAccessKeyId"] = @@access_key  

    return parameters
  end

  def get_fps_url(params)
    fpsURL = @@service_end_point + "?"
    isFirst = true
    params.each { |k,v|
      if(isFirst) then
        isFirst = false
      else
        fpsURL << '&'
      end

      fpsURL << Amazon::FPS::SignatureUtils.urlencode(k)
      unless(v.nil?) then
        fpsURL << '='
        fpsURL << Amazon::FPS::SignatureUtils.urlencode(v)
      end
    }
    return fpsURL
  end 
  
  def get_formatted_timestamp()
    return Time.now.iso8601.to_s
  end

  def send(multi_use_token, recipient_token, amount)
    uri = URI.parse(@@service_end_point)
		
		params = get_fps_default_parameters()

		puts 'recptoken', recipient_token
		puts 'multiuse_token', multi_use_token

		params["Action"] = "Pay"
    params["CallerReference"] = rand(9999999)
		params["RecipientTokenId"] = recipient_token
		params["SenderTokenId"] = multi_use_token
		params["TransactionAmount.Value"] = amount
		params["TransactionAmount.CurrencyCode"] = "USD"

    #Sample GetTransactionStatusRequest
    params[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
    params[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM
    signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => params, 
                                            :aws_secret_key => @@secret_key,
                                            :host => uri.host,
                                            :verb => @@http_method,
                                            :uri  => uri.path })
    params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature

		return self.class.get(@@service_end_point, :query => params)
	end
end

end
end
