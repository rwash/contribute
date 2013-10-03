require 'base64'
require 'openssl'

module Amazon
  module FPS
    class OutboundSignatureV2
      include ActiveModel::Validations

      def initialize(parameters, http_method, url_end_point)
        @parameters = parameters
        @http_method = http_method
        @url_end_point = url_end_point
      end

      def self.signature_version
        "2"
      end
      attr_reader :parameters, :http_method, :url_end_point

      validate :parameters_are_enumerable
      validates :signature, presence: true
      validates :signature_version, presence: true, inclusion: { in: [signature_version] }
      validates :signature_method, presence: true
      validates :signature_algorithm, presence: true
      validates :certificate_url, presence: true

      def validate
        unless self.valid?
          raise errors.inspect
        end

        # Construct VerifySignatureAPI request
        if SignatureUtilsForOutbound::starts_with(certificate_url, FPS_SANDBOX_ENDPOINT) then
          verify_signature_request = FPS_SANDBOX_ENDPOINT
        elsif SignatureUtilsForOutbound::starts_with(certificate_url, FPS_PROD_ENDPOINT) then
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

        return (status_el && status_el.text == "Success")
      end

      private

      def signature
        @signature ||= parameters[SIGNATURE_KEYNAME]
      end

      def signature_version
        @signature_version ||= parameters[SIGNATURE_VERSION_KEYNAME]
      end

      def signature_method
        @signature_method ||= parameters[SIGNATURE_METHOD_KEYNAME]
      end

      def signature_algorithm
        @signature_algorithm ||= SignatureUtilsForOutbound::get_algorithm(signature_method)
      end

      def certificate_url
        @certificate_url ||= parameters[CERTIFICATE_URL_KEYNAME]
      end

      def parameters_are_enumerable
        unless parameters.kind_of? Enumerable
          errors.add :parameters, "must be enumerable"
        end
      end
    end
  end
end
