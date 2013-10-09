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
        handle_failing_validations
        verify_signature_status && verify_signature_status.text == "Success"
      end

      private

      def handle_failing_validations
        unless self.valid?
          raise errors.inspect
        end
      end

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
        prefix = endpoint + '?'
        prefix + encoded_request_parameters
      end

      def endpoint
        endpoint = base_url_regex.match(certificate_url).to_a.first
        handle_unacceptable_endpoint(endpoint)
        endpoint
      end

      def handle_unacceptable_endpoint endpoint
        unless acceptable_endpoints.include? endpoint
          raise "'certificateUrl' received is not valid. Should be one of: #{acceptable_endpoints}"
        end
      end

      def base_url_regex
        /^http[s]?:\/\/[a-zA-Z\.]*\//
      end

      def acceptable_endpoints
        [
          "https://fps.sandbox.amazonaws.com/",
          "https://fps.amazonaws.com/"
        ]
      end

      def encoded_request_parameters
        verify_signature_params.map do |key, value|
          "#{key}=#{Web::url_encode(value)}"
        end.join '&'
      end

      def verify_signature_params
        {
          'Action' => 'VerifySignature',
          'UrlEndPoint' => url_end_point,
          'Version' => '2008-09-17',
          'HttpParameters' => encoded_response_parameters
        }
      end

      def encoded_response_parameters
        parameters.map do |(k, v)|
          Web::url_encode(k) + "=" + Web::url_encode(v)
        end.join("&")
      end

      def signature
        @signature ||= parameters["signature"]
      end

      def signature_version
        parameters['signatureVersion']
      end

      def signature_method
        @signature_method ||= parameters['signatureMethod']
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
