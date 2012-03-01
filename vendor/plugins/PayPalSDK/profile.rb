# The module has a class which holds merchant's API credentials and PayPal endpoint information.  

module PayPalSDKProfiles
  class Profile         
    cattr_accessor :headers 
    cattr_accessor :endpoints 
    cattr_accessor :client_info 
    cattr_accessor :proxy_info 
    cattr_accessor :DEV_CENTRAL_URL
    cattr_accessor :client_details
    cattr_accessor :PAYPAL_Redirect_URL
    
    

#Developer central URL
    @@DEV_CENTRAL_URL="https://developer.paypal.com"
    @@PAYPAL_Redirect_URL="https://www.sandbox.paypal.com/webscr?cmd="
###############################################################################################################################    
#    NOTE: Production code should NEVER expose API credentials in any way! They must be managed securely in your application.
#    To generate a Sandbox API Certificate, follow these steps: https://www.paypal.com/IntegrationCenter/ic_certificate.html
###############################################################################################################################
# specify the 3-token values.    
@@headers = {"X-PAYPAL-SERVICE-VERSION" => "1.0.0","X-PAYPAL-SECURITY-USERID" => "platfo_1255077030_biz_api1.gmail.com","X-PAYPAL-SECURITY-PASSWORD" =>"1255077037", "X-PAYPAL-SECURITY-SIGNATURE" => "Abg0gYcQyxQvnf2HDJkKtA-p6pqhA1k-KTYE0Gcy1diujFio4io5Vqjf", "X-PAYPAL-APPLICATION-ID" => "APP-80W284485P519543T","X-PAYPAL-DEVICE-IPADDRESS"=>"127.0.0.1" , "X-PAYPAL-REQUEST-DATA-FORMAT" => "NV" , "X-PAYPAL-RESPONSE-DATA-FORMAT" => "NV"}



# endpoint of PayPal server against which call will be made.    
@@endpoints = {"SERVER" => "svcs.sandbox.paypal.com", "PORT" => "443", "SERVICE" =>""}

#Client details to be send in request
@@client_details ={"ipAddress"=>"127.0.0.1", "deviceId"=>"mydevice", "applicationId"=>"APP-80W284485P519543T"}
    

# Proxy information of the client environment.    
@@proxy_info = {"USE_PROXY" => false, "ADDRESS" => nil, "PORT" => "443", "USER" => nil, "PASSWORD" => nil }
    
# Information needed for tracking purposes.    
   @@client_info = { "VERSION" => "64.0", "SOURCE" => "PayPalRubySDKV1.2.0"}   
 
  def initialize
      config
    end
 def config
     @config ||= YAML.load_file("./script/../config/paypal.yml")     
 end
 
 def m_use_proxy
   @config[:USE_PROXY]
 end
end

   
end



