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

	def self.format_return_url(return_url)
		return "http://#{return_url}"
	end
end
 
end
end
