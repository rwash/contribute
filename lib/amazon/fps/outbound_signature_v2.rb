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

      attr_reader :parameters, :http_method, :url_end_point

      validate :parameters_are_enumerable
      validates :signature, presence: true
      validates :signature_version, presence: true, inclusion: { in: ["2"] }
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

      def verify_signature_endpoint
        endpoint = base_url_regex.match(certificate_url).to_a.first
        unless acceptable_verify_signature_endpoints.include? endpoint
          raise "'certificateUrl' received is not valid. Should be one of: #{acceptable_verify_signature_endpoints}"
        end
        endpoint
      end

      def base_url_regex
        /^http[s]?:\/\/[a-zA-Z\.]*\//
      end

      def acceptable_verify_signature_endpoints
        [
          "https://fps.sandbox.amazonaws.com/",
          "https://fps.amazonaws.com/"
        ]
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
        parameters[CERTIFICATE_URL_KEYNAME]
      end

      def parameters_are_enumerable
        unless parameters.kind_of? Enumerable
          errors.add :parameters, "must be enumerable"
        end
      end
    end
  end
end
