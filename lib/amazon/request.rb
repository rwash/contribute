module Amazon
  class Request
    def initialize
    end

    protected
    def http_method
      "GET"
    end

    def access_key
      AmazonFlexPay.access_key
    end

    def secret_key
      AmazonFlexPay.secret_key
    end

    def default_params
      {
        Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME => "2",
        Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME => Amazon::FPS::SignatureUtils::HMAC_SHA256_ALGORITHM,
      }
    end

    def caller_reference
      @_caller_reference ||= UUIDTools::UUID.random_create.to_s
    end

    def set_signature
      @params[Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME] = signature
    end

    def signature
      @_signature ||= begin
                        uri = URI.parse(service_end_point)
                        Amazon::FPS::SignatureUtils.sign_parameters({
                          parameters: @params,
                          host: uri.host,
                          verb: http_method,
                          uri: uri.path,
                        })
                      end
    end
  end
end
