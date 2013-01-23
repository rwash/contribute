require 'net/http'
require 'amazon/fps/signatureutils'

module Amazon
  module FPS

    # The base fps request provides the foundation to perform the restful interactionbetween contribute and amazon.
    # We use HTTParty for this.  It differs from CBUI requests because the user is not redirected to amazon to sign in,
    # the server just sends the request to amazon
    class BaseFpsRequest
      include HTTParty
      format :xml

      #Like CBUI, the BaseFpsRequest initialize fills in common parameters within the contructor
      def initialize
        @app_name = "FPS"
        @http_method = "GET"
        @service_end_point = Rails.application.config.amazon_fps_endpoint
        @version = "2008-09-17"

        @access_key = Rails.application.config.aws_access_key
        @secret_key = Rails.application.config.aws_secret_key
        @params = get_default_parameters()
      end

      def get_default_parameters()
        params = {}
        params["Version"] = @version
        params["Timestamp"] = get_formatted_timestamp()
        params["AWSAccessKeyId"] = @access_key
        params["CallerReference"] = UUIDTools::UUID.random_create.to_s
        params[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME] = "2"
        params[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME] = Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM

        return params
      end

      #converts the current time to ISO 8601 format
      def get_formatted_timestamp()
        return Time.now.iso8601.to_s
      end

      # The response for the created request is returned.
      # The request and response are logged within this function.
      # The signature is also created before being sent
      def send()
        uri = URI.parse(@service_end_point)
        signature = Amazon::FPS::SignatureUtils.sign_parameters({:parameters => @params, 
                                                                :aws_secret_key => @secret_key,
                                                                :host => uri.host,
                                                                :verb => @http_method,
                                                                :uri  => uri.path })
        @params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature

        request = log_request(@params)
        response = self.class.get(@service_end_point, :query => @params)
        response = strip_response(response)

        log_response(response, request)
        return response
      end
    end

  end
end
