module Amazon
  class Request
    def initialize
    end

    protected
    attr_reader :params

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
      @_signature ||= sign_parameters
    end

    def uri
      URI.parse(service_end_point)
    end

    def uri_host
      uri.host
    end

    def uri_path
      uri.path
    end

    def sign_parameters
      signature_version = params[Amazon::FPS::SignatureUtils::SIGNATURE_VERSION_KEYNAME]
      string_to_sign = "";
      algorithm = 'sha1';
      if (signature_version == '1') then
        string_to_sign = calculate_string_to_sign_v1
      elsif (signature_version == '2') then
        algorithm = get_algorithm(params[Amazon::FPS::SignatureUtils::SIGNATURE_METHOD_KEYNAME])
        string_to_sign = calculate_string_to_sign_v2
      else
        raise "Invalid Signature Version specified"
      end
      return compute_signature(string_to_sign, algorithm)
    end

    def calculate_string_to_sign_v1
      # exclude any existing Signature parameter from the canonical string
      canonical = ''
      signable_params.each do |v|
        canonical << v[0]
        canonical << v[1] unless(v[1].nil?)
      end

      return canonical
    end

    def calculate_string_to_sign_v2
      uri = uri_path
      uri = "/" if uri.nil? or uri.empty?
      uri = urlencode(uri).gsub("%2F", "/")

      verb = http_method
      host = uri_host.downcase

      canonical_header = "#{verb}\n#{host}\n#{uri}\n"

      canonical_params = signable_params.map do |assignment|
        assignment.map {|element| urlencode(element)}.join '='
      end.join '&'

      canonical_header + canonical_params
    end

    def signable_params
      params.reject do |k, v|
        k == Amazon::FPS::SignatureUtils::SIGNATURE_KEYNAME
      end.sort
    end

    def get_algorithm(signature_method)
      if signature_method == default_signature_method
        'sha256'
      else
        'sha1'
      end
    end

    def compute_signature(canonical, algorithm = 'sha1')
      digest = OpenSSL::Digest::Digest.new(algorithm)
      return Base64.encode64(OpenSSL::HMAC.digest(digest, secret_key, canonical)).chomp
    end

    def urlencode(string)
      Amazon::FPS::SignatureUtilsForOutbound::urlencode(string)
    end
  end
end
