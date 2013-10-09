require 'amazon/web'

module Amazon
  class Request
    include Amazon::Web

    protected
    attr_reader :params

    SIGNATURE_VERSION = 'SignatureVersion'
    SIGNATURE_METHOD = 'SignatureMethod'
    SIGNATURE = 'Signature'

    def http_method
      "GET"
    end

    def access_key
      Rails.application.config.aws_access_key
    end

    def secret_key
      Rails.application.config.aws_secret_key
    end

    def default_params
      {
        SIGNATURE_VERSION => "2",
        SIGNATURE_METHOD => "HmacSHA256",
      }
    end

    def caller_reference
      @_caller_reference ||= UUIDTools::UUID.random_create.to_s
    end

    def set_signature
      @params[SIGNATURE] = signature
    end

    def signature
      @_signature ||= begin
                        validate_correct_signature_version
                        Base64.encode64(OpenSSL::HMAC.digest(digest, secret_key, string_to_sign)).chomp
                      end
    end

    def digest
      OpenSSL::Digest::Digest.new(algorithm)
    end

    def uri
      URI.parse(service_end_point)
    end

    def uri_host
      uri.host.downcase
    end

    def validate_correct_signature_version
      unless signature_version == "2"
        raise "Error. Signature version should be 2"
      end
    end

    def signature_version
      params[SIGNATURE_VERSION]
    end

    def string_to_sign
      canonical_header + canonical_params
    end

    def canonical_header
      "#{http_method}\n#{uri_host}\n#{uri_path}\n"
    end

    def canonical_params
      signable_params.map do |assignment|
        assignment.map {|element| Web::url_encode(element)}.join '='
      end.join '&'
    end

    def uri_path
      path = uri.path.presence || '/'
      Web::url_encode(path).gsub("%2F", "/")
    end

    def signable_params
      params.reject do |k, v|
        k == SIGNATURE
      end.sort
    end

    def algorithm
      'sha256'
    end
  end
end
