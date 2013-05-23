require 'base64'
require 'openssl'

module Amazon
  module FPS
    class OutboundSignatureV2
      def initialize(args)
        @args = args
      end

      def validate
        [:parameters, :http_method, :url_end_point].each do |arg|
          raise "#{arg.inspect} is missing from the arguments." unless @args[arg]
        end

        url_end_point = @args[:url_end_point]

        parameters = @args[:parameters]
        raise ":parameters must be enumerable" unless @args[:parameters].kind_of? Enumerable

        signature = parameters[SIGNATURE_KEYNAME];
        raise "'signature' is missing from the parameters." if (signature.nil? or signature.empty?)

        signature_version = parameters[SIGNATURE_VERSION_KEYNAME];
        raise "'signatureVersion' is missing from the parameters." if (signature_version.nil? or signature_version.empty?)
        raise "'signatureVersion' present in parameters is invalid. Valid values are: 2" if (signature_version != SIGNATURE_VERSION_2)

        signature_method = parameters[SIGNATURE_METHOD_KEYNAME]
        raise "'signatureMethod' is missing from the parameters." if (signature_method.nil? or signature_method.empty?)
        signature_algorithm = SignatureUtilsForOutbound::get_algorithm(signature_method)
        raise "'signatureMethod' present in parameters is invalid. Valid values are: RSA-SHA1" if (signature_algorithm.nil?)

        certificate_url = parameters[CERTIFICATE_URL_KEYNAME]
        raise "'certificate_url' is missing from the parameters." if (certificate_url.nil? or certificate_url.empty?)

        # Construct VerifySignatureAPI request
        if(SignatureUtilsForOutbound::starts_with(certificate_url, FPS_SANDBOX_ENDPOINT) == true) then
          verify_signature_request = FPS_SANDBOX_ENDPOINT
        elsif(SignatureUtilsForOutbound::starts_with(certificate_url, FPS_PROD_ENDPOINT) == true) then
          verify_signature_request = FPS_PROD_ENDPOINT
        else
          raise "'certificateUrl' received is not valid. Valid certificate urls start with " <<
          CERTIFICATE_URL_ROOT << " or " << CERTIFICATE_URL_ROOT_SANDBOX << "."
        end

        verify_signature_request = verify_signature_request + ACTION_PARAM +
          END_POINT_PARAM +
          SignatureUtilsForOutbound::urlencode(url_end_point) +
          VERSION_PARAM_VALUE +
          HTTP_PARAMS_PARAM +
          SignatureUtilsForOutbound::urlencode(SignatureUtilsForOutbound::get_http_params(parameters))
        verify_signature_response = SignatureUtilsForOutbound::get_http_data(verify_signature_request)

        # parse the response
        document = REXML::Document.new(verify_signature_response)

        status_el = document.elements['VerifySignatureResponse/VerifySignatureResult/VerificationStatus']
        return (!status_el.nil? && status_el.text == "Success")
      end

      private
    end
  end
end
