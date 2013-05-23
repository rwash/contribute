require 'base64'
require 'openssl'

module Amazon
  module FPS
    class OutboundSignatureV1
      def initialize(args)
        @args = args
      end

      def validate
        if signature.nil?
          raise "Signature is missing from parameters"
        end

        return signature == Base64.encode64(OpenSSL::HMAC.digest(digest, @aws_secret_key, canonical)).chomp
      end

      private

      def signature
        parameters = @args[:parameters]
        signature = "";
        signature = parameters[SIGNATURE_KEYNAME];
      end

      def canonical
        parameters = @args[:parameters]

        # exclude any existing Signature parameter from the canonical string
        sorted = (parameters.reject { |k, v| ((k == SIGNATURE_KEYNAME)) }).sort { |a,b| a[0].downcase <=> b[0].downcase }

        canonical = ''
        sorted.each do |v|
          canonical << v[0]
          canonical << v[1] unless(v[1].nil?)
        end

        return canonical
      end

      def digest
        OpenSSL::Digest::Digest.new('sha1')
      end

    end
  end
end
