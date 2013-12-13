require 'net/http'
require 'amazon/request'
require 'amazon/fps/signatureutils'

module Amazon
  module FPS

    # The base fps request provides the foundation to perform the restful interactionbetween contribute and amazon.
    # We use HTTParty for this.  It differs from CBUI requests because the user is not redirected to amazon to sign in,
    # the server just sends the request to amazon
    class BaseFpsRequest < Amazon::Request
      include HTTParty
      format :xml

      #Like CBUI, the BaseFpsRequest initialize fills in common parameters within the contructor
      def initialize
        @params = default_params()
      end

      def default_params()
        params = super
        params["Version"] = version
        params["Timestamp"] = formatted_timestamp()
        params["AWSAccessKeyId"] = access_key
        params["CallerReference"] = caller_reference
        return params
      end

      def version
        "2008-09-17"
      end

      def app_name
        "FPS"
      end

      def service_end_point
        AmazonFlexPay.api_endpoint
      end

      #converts the current time to ISO 8601 format
      def formatted_timestamp()
        return Time.now.iso8601.to_s
      end

      # The response for the created request is returned.
      # The request and response are logged within this function.
      # The signature is also created before being sent
      def send()
        set_signature

        request = log_request(@params)
        response = self.class.get(service_end_point, query: @params)
        response = strip_response(response)

        log_response(response, request)
        return response
      end
    end
  end
end
