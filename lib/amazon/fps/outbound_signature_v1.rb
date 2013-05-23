require 'base64'
require 'openssl'

module Amazon
  module FPS
    class OutboundSignatureV1
      include ActiveModel::Validations

      attr_reader :parameters

      def initialize(parameters)
        @parameters = parameters
      end

      validate :signature, presence: true
      validate :signature_matches_hash

      # TODO extract this into calling class
      def validate
        raise "Invalid outbound signature" unless valid?
      end

      private

      def signature
        @signature ||= parameters[SIGNATURE_KEYNAME];
      end

      def digest
        OpenSSL::Digest::Digest.new('sha1')
      end

      def signature_matches_hash
        signature == Base64.encode64(OpenSSL::HMAC.digest(digest, @aws_secret_key, canonical)).chomp
      end

      def canonical
        # exclude any existing Signature parameter from the canonical string
        unsigned_parameters = parameters.reject { |k, v| ((k == SIGNATURE_KEYNAME)) }
        sorted_unsigned_parameters = unsigned_parameters.sort { |a,b| a[0].downcase <=> b[0].downcase }

        canonical = ''
        sorted_unsigned_parameters.each do |v|
          canonical << v[0]
          canonical << v[1] unless(v[1].nil?)
        end

        return canonical
      end
    end
  end
end
