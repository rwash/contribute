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

        verify_signature_status && verify_signature_status.text == "Success"
      end

      private

      def verify_signature_status
        verify_signature_response_document.elements[verify_signature_document_path]
      end

      def verify_signature_document_path
        'VerifySignatureResponse/VerifySignatureResult/VerificationStatus'
      end

      def verify_signature_response_document
        REXML::Document.new(verify_signature_response)
      end

      def verify_signature_response
        SignatureUtilsForOutbound::get_http_data(verify_signature_request)
      end

      def verify_signature_request
        prefix = verify_signature_endpoint + '?'
        prefix + encoded_parameter_strings.join('&')
      end

      def encoded_parameter_strings
        [].tap do |encoded_parameter_strings|
          verify_signature_params.each_pair do |key, value|
            encoded_value = SignatureUtilsForOutbound::urlencode(value)
            encoded_parameter_strings << "#{key}=#{encoded_value}"
          end
        end
      end

      def verify_signature_params
        {
          'Action' => 'VerifySignature',
          'UrlEndPoint' => url_end_point,
          'Version' => '2008-09-17',
          'HttpParameters' => SignatureUtilsForOutbound::get_http_params(parameters),
        }
      end

      def verify_signature_endpoint
        if starts_with(certificate_url, FPS_SANDBOX_ENDPOINT) then
          FPS_SANDBOX_ENDPOINT
        elsif starts_with(certificate_url, FPS_PROD_ENDPOINT) then
          FPS_PROD_ENDPOINT
        else
          raise "'certificateUrl' received is not valid. Valid certificate urls start with " <<
          CERTIFICATE_URL_ROOT << " or " << CERTIFICATE_URL_ROOT_SANDBOX << "."
        end
      end

      def starts_with(string, prefix)
        prefix = prefix.to_s
        string[0, prefix.length] == prefix
      end

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
