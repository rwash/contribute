require 'base64'
require 'cgi'
require 'openssl'

module Amazon
  module FPS
    class SignatureUtils
      SIGNATURE_KEYNAME = "Signature"
      SIGNATURE_METHOD_KEYNAME = "SignatureMethod"
      SIGNATURE_VERSION_KEYNAME = "SignatureVersion"
    end
  end
end
