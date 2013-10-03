require 'base64'
require 'cgi'
require 'openssl'

module Amazon
module FPS

class SignatureUtils

  SIGNATURE_KEYNAME = "Signature"
  SIGNATURE_METHOD_KEYNAME = "SignatureMethod"
  SIGNATURE_VERSION_KEYNAME = "SignatureVersion"

  HMAC_SHA256_ALGORITHM = "HmacSHA256"
  HMAC_SHA1_ALGORITHM = "HmacSHA1"

  def self.sign_parameters(args)
    signature_version = args[:parameters][SIGNATURE_VERSION_KEYNAME]
    string_to_sign = "";
    algorithm = 'sha1';
    if (signature_version == '1') then
      string_to_sign = calculate_string_to_sign_v1(args)
    elsif (signature_version == '2') then
      algorithm = get_algorithm(args[:parameters][SIGNATURE_METHOD_KEYNAME])
      string_to_sign = calculate_string_to_sign_v2(args)
    else
      raise "Invalid Signature Version specified"
    end
    return compute_signature(string_to_sign, args[:aws_secret_key], algorithm)
  end
  
  # Convert a string into URL encoded form.
  def self.urlencode(plaintext)
    CGI.escape(plaintext.to_s).gsub("+", "%20").gsub("%7E", "~")
  end

  private # All the methods below are private

  def self.calculate_string_to_sign_v1(args)
    parameters = args[:parameters]

    # exclude any existing Signature parameter from the canonical string
    sorted = (parameters.reject { |k, v| k == SIGNATURE_KEYNAME }).sort { |a,b| a[0].downcase <=> b[0].downcase }
    
    canonical = ''
    sorted.each do |v|
      canonical << v[0]
      canonical << v[1] unless(v[1].nil?)
    end

    return canonical
  end

  def self.calculate_string_to_sign_v2(args)
    parameters = args[:parameters]

    uri = args[:uri] 
    uri = "/" if uri.nil? or uri.empty?
    uri = urlencode(uri).gsub("%2F", "/") 

    verb = args[:verb]
    host = args[:host].downcase

    canonical_header = "#{verb}\n#{host}\n#{uri}\n"

    acceptable_params = parameters.reject { |k, v| k == SIGNATURE_KEYNAME }
    sorted_params = acceptable_params.sort

    canonical_params = sorted_params.map do |assignment|
      assignment.map {|element| urlencode(element)}.join '='
    end.join '&'

    canonical_header + canonical_params
  end

  def self.get_algorithm(signature_method) 
    if signature_method == HMAC_SHA256_ALGORITHM
      'sha256'
    else
      'sha1'
    end
  end

  def self.compute_signature(canonical, aws_secret_key, algorithm = 'sha1')
    digest = OpenSSL::Digest::Digest.new(algorithm)
    return Base64.encode64(OpenSSL::HMAC.digest(digest, aws_secret_key, canonical)).chomp
  end

end

end
end

