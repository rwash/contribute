require 'uri'
require 'amazon/request'
require 'amazon/fps/signatureutils'

module Amazon
  module FPS

    #These calls redirect the user to amazon's web page in order to sign in and accept or make payments.  http://docs.amazonwebservices.com/AmazonFPS/latest/FPSAdvancedGuide/CHAP_IntroductionUIPipeline.html
    class BaseCbuiRequest < Amazon::Request

      #common parameters are filled in for the derived classes
      def initialize
        @params = default_params()
      end

      def app_name
        "CBUI"
      end

      def service_end_point
        Rails.application.config.amazon_cbui_endpoint
      end

      def version
        "2009-01-09"
      end

      def default_params()
        params = super
        params["callerKey"] = access_key
        params["version"] = version
        params["callerReference"] = caller_reference
        return params
      end

      #formats the incoming parameters into a nice query string that is appended to the endpoint.  we redirect the user to the returned url
      def url()
        set_signature
        service_end_point + "?" + encoded_params
      end

      private

      def encoded_params
        @params.map do |key,value|
          "#{key}=#{SignatureUtils::urlencode(value)}"
        end.join '&'
      end
    end

  end
end

