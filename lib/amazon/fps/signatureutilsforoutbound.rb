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

  USER_AGENT_STRING = "SigV2_MigrationSampleCode_Ruby-2010-09-13"

  RSA_SHA1_ALGORITHM = "RSA-SHA1"


    class SignatureUtilsForOutbound

  def initialize(aws_access_key, aws_secret_key)
    @aws_secret_key = aws_secret_key
    @aws_access_key = aws_access_key
  end

      def validate_request(args)
        @args = args
        signature.validate
      end

      private

      attr_reader :args

      def signature
        if version_number(args[:parameters]) == 2
          OutboundSignatureV2.new(args[:parameters], args[:http_method], args[:url_end_point])
        else
          OutboundSignatureV1.new(args[:parameters])
        end
      end

  public
  def self.get_algorithm(signature_method) 
    if (signature_method == "RSA-SHA1")
      OpenSSL::Digest::SHA1.new
    else
      nil
    end
  end

  def self.urlencode(plaintext)
    Amazon::FPS::SignatureUtils.urlencode(plaintext)
  end

  def self.get_http_data(url)
    #2. fetch certificate if not found in cache
    uri = URI.parse(url)
    http_session = Net::HTTP.new(uri.host, uri.port)
    http_session.use_ssl = true
    http_session.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http_session.verify_depth = 5

    res = http_session.start {|session|
      req = Net::HTTP::Get.new(url, {"User-Agent" => USER_AGENT_STRING})
      session.request(req)
    }

    return res.body
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

