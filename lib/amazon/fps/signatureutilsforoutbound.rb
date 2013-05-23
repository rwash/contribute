###############################################################################
 #  Copyright 2008-2010 Amazon Technologies, Inc
 #  Licensed under the Apache License, Version 2.0 (the "License");
 #
 #  You may not use this file except in compliance with the License.
 #  You may obtain a copy of the License at: http://aws.amazon.com/apache2.0
 #  This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 #  CONDITIONS OF ANY KIND, either express or implied. See the License for the
 #  specific language governing permissions and limitations under the License.
 ##############################################################################

require 'base64'
require 'cgi'
require 'openssl'
require 'net/http'
require 'net/https'
require 'rexml/document'

module Amazon
module FPS

  SIGNATURE_KEYNAME = "signature"
  SIGNATURE_METHOD_KEYNAME = "signatureMethod"
  SIGNATURE_VERSION_KEYNAME = "signatureVersion"
  CERTIFICATE_URL_KEYNAME = "certificateUrl"
  CERTIFICATE_URL_ROOT = "https://fps.amazonaws.com/"
  CERTIFICATE_URL_ROOT_SANDBOX = "https://fps.sandbox.amazonaws.com/"

  FPS_PROD_ENDPOINT = CERTIFICATE_URL_ROOT
  FPS_SANDBOX_ENDPOINT = CERTIFICATE_URL_ROOT_SANDBOX
  ACTION_PARAM = "?Action=VerifySignature"
  END_POINT_PARAM = "&UrlEndPoint="
  HTTP_PARAMS_PARAM = "&HttpParameters="
  VERSION_PARAM_VALUE = "&Version=2008-09-17"

  USER_AGENT_STRING = "SigV2_MigrationSampleCode_Ruby-2010-09-13"

  SIGNATURE_VERSION_1 = "1"
  SIGNATURE_VERSION_2 = "2"
  RSA_SHA1_ALGORITHM = "RSA-SHA1"


class SignatureUtilsForOutbound

  def initialize(aws_access_key, aws_secret_key)
    @aws_secret_key = aws_secret_key
    @aws_access_key = aws_access_key
  end

  def validate_request(args)
    if version_number(args[:parameters]) == 2
      return validate_signature_v2(args)
    else
      return validate_signature_v1(args)
    end
  end

  def validate_signature_v1(args)
    signature = OutboundSignatureV1.new(args[:parameters])
    signature.validate
  end

  def validate_signature_v2(args)
    signature = OutboundSignatureV2.new(args[:parameters], args[:http_method], args[:url_end_point])
    signature.validate
  end

  def self.get_algorithm(signature_method) 
    return OpenSSL::Digest::SHA1.new if (signature_method == RSA_SHA1_ALGORITHM)
    return nil
  end

  # Convert a string into URL encoded form.
  def self.urlencode(plaintext)
    CGI.escape(plaintext.to_s).gsub("+", "%20").gsub("%7E", "~")
  end
   
  def self.get_http_data(url)
    #2. fetch certificate if not found in cache
    uri = URI.parse(url)
    http_session = Net::HTTP.new(uri.host, uri.port)
    http_session.use_ssl = true
    http_session.ca_file = '/etc/ssl/certs/ca-certificates.crt'
    http_session.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http_session.verify_depth = 5

    res = http_session.start {|http_session|
      req = Net::HTTP::Get.new(url, {"User-Agent" => USER_AGENT_STRING})
      http_session.request(req)
    }

    return res.body
  end

  def self.starts_with(string, prefix)
    prefix = prefix.to_s
    string[0, prefix.length] == prefix
  end
  
  def self.get_http_params(params)
     params.map do |(k, v)|
        urlencode(k) + "=" + urlencode(v)
     end.join("&")
  end

  private

  def version_number(parameters)
    parameters[SIGNATURE_VERSION_KEYNAME].to_i
  end

end

end
end

