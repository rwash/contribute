require 'uri'
require 'amazon/fps/signatureutils'

module Amazon
module FPS

#These calls redirect the user to amazon's web page in order to sign in and accept or make payments.  http://docs.amazonwebservices.com/AmazonFPS/latest/FPSAdvancedGuide/CHAP_IntroductionUIPipeline.html
class BaseCbuiRequest

	#common parameters are filled in for the derived classes
	def initialize
		@app_name = "CBUI"
		@http_method = "GET"
		@service_end_point = Rails.application.config.amazon_cbui_endpoint
		@cbui_version = "2009-01-09"

		@access_key = Rails.application.config.aws_access_key
		@secret_key = Rails.application.config.aws_secret_key
		@params = get_default_params()
	end

	def get_default_params()
		params = {}
		params["callerKey"] = @access_key
		params["version"] = @cbui_version
		params["callerReference"] = UUIDTools::UUID.random_create.to_s
		params[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
		params[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM
	
		return params
	end

	#creates the signature from the incoming endpoint, and parameters.  Then returns the formatted url from get_url()
	def url()
			uri = URI.parse(@service_end_point)
			signature = Amazon::FPS::SignatureUtils.sign_parameters({parameters: @params, 
																							aws_secret_key: @secret_key,
																							host: uri.host,
																							verb: @http_method,
																							uri:  uri.path })
			@params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature

			return get_url(@service_end_point, @params)
	end

	#formats the incoming parameters into a nice query string that is appended to the endpoint.  we redirect the user to the returned url
	def get_url(service_end_point, params)
		url = service_end_point + "?"

		isFirst = true
		params.each { |k,v|
			if(isFirst) then
				isFirst = false
			else
				url << '&'
			end

			url << Amazon::FPS::SignatureUtils.urlencode(k)
			unless(v.nil?) then
				url << '='
				url << Amazon::FPS::SignatureUtils.urlencode(v)
			end
			}
		return url
  end 
end

end
end

