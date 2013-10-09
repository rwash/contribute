module Amazon
  class Request
    def initialize
    end

    protected
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
        Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME => "2",
        Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME => default_signature_method,
      }
    end

    def default_signature_method
      "HmacSHA256"
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
                        sign_parameters({
                          parameters: @params,
                          aws_secret_key: secret_key,
                          host: uri.host,
                          verb: http_method,
                          uri: uri.path,
                        })
                      end
    end

    def sign_parameters(args)
      signature_version = args[:parameters][Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME]
      string_to_sign = "";
      algorithm = 'sha1';
      if (signature_version == '1') then
        string_to_sign = calculate_string_to_sign_v1(args)
      elsif (signature_version == '2') then
        algorithm = get_algorithm(args[:parameters][Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME])
        string_to_sign = calculate_string_to_sign_v2(args)
      else
        raise "Invalid Signature Version specified"
      end
      return compute_signature(string_to_sign, args[:aws_secret_key], algorithm)
    end

    def calculate_string_to_sign_v1(args)
      parameters = args[:parameters]

      # exclude any existing Signature parameter from the canonical string
      sorted = (parameters.reject { |k, v| k == Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME }).sort { |a,b| a[0].downcase <=> b[0].downcase }

      canonical = ''
      sorted.each do |v|
        canonical << v[0]
        canonical << v[1] unless(v[1].nil?)
      end

      return canonical
    end

    def calculate_string_to_sign_v2(args)
      parameters = args[:parameters]

      uri = args[:uri]
      uri = "/" if uri.nil? or uri.empty?
      uri = urlencode(uri).gsub("%2F", "/")

      verb = args[:verb]
      host = args[:host].downcase

      canonical_header = "#{verb}\n#{host}\n#{uri}\n"

      acceptable_params = parameters.reject { |k, v| k == Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME }
      sorted_params = acceptable_params.sort

      canonical_params = sorted_params.map do |assignment|
        assignment.map {|element| urlencode(element)}.join '='
      end.join '&'

      canonical_header + canonical_params
    end

    def get_algorithm(signature_method)
      if signature_method == default_signature_method
        'sha256'
      else
        'sha1'
      end
    end

    def compute_signature(canonical, aws_secret_key, algorithm = 'sha1')
      digest = OpenSSL::Digest::Digest.new(algorithm)
      return Base64.encode64(OpenSSL::HMAC.digest(digest, aws_secret_key, canonical)).chomp
    end

    def urlencode(string)
      Amazon::FPS::SignatureUtilsForOutbound::urlencode(string)
    end
  end
end
