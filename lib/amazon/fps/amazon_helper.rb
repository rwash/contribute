require 'amazon/fps/signatureutilsforoutbound'

module Amazon
module FPS

class AmazonHelper
  def self.get_url(service_end_point, params)
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

	def self.valid_response(params, url_end_point)
		access_key = Rails.application.config.aws_access_key
		secret_key = Rails.application.config.aws_secret_key
		utils = Amazon::FPS::SignatureUtilsForOutbound.new(access_key, secret_key)

		#This is rails garbage we don't need to send to amazon
		params.delete("controller")
		params.delete("action")

		puts 'params in amazon helper', params
		return utils.validate_request(:parameters => params, :url_end_point => url_end_point, :http_method => "GET")	
	end
end
 
end
end
