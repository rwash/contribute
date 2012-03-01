require 'net/http'
require 'net/https'
require 'uri'
require 'profile'
require 'utils'
require 'logger'
# The module has a class and a wrapper method wrapping NET:HTTP methods to simplify calling PayPal APIs.

module PayPalSDKCallers 


  class Caller    
    include PayPalSDKProfiles
    include PayPalSDKUtils
    attr_reader :ssl_strict
    # to make long names shorter for easier access and to improve readability define the following variables
    @@profile = PayPalSDKProfiles::Profile
    # Proxy server information hash
    @@pi=@@profile.proxy_info
    # merchant credentials hash
    @@cre=@@profile.headers
    # client information such as version, source hash
    @@ci=@@profile.client_info
    # endpoints of PayPal hash
    @@ep=@@profile.endpoints     
    #@@PayPalLog=PayPalSDKUtils::Logger.getLogger('PayPal.log')    
    # CTOR
    def initialize(ssl_verify_mode=false)
      @ssl_strict = ssl_verify_mode  
      @@headers =@@cre
      @profile =PayPalSDKProfiles::Profile.new
    end   
    
       # Condition to test whether header value "X-PAYPAL-REQUEST-SOURCE" is available
        @@headers =@@cre
        if  (@@headers.has_key?("X-PAYPAL-REQUEST-SOURCE"))
            @@headers["X-PAYPAL-REQUEST-SOURCE"]="RUBY_NVP_SDK_V1.0" + "- " + @@headers["X-PAYPAL-REQUEST-SOURCE"]   
        else
            @@headers["X-PAYPAL-REQUEST-SOURCE"]= "RUBY_NVP_SDK_V1.0"
        end
   
    # This method uses HTTP::Net library to talk to PayPal WebServices. This is the method what merchants should mostly care about.
    # It expects an hash arugment which has the method name and paramter values of a particular PayPal API.
    # It assumes and uses the credentials of the merchant which is the attribute value of credentials of profile class in PayPalSDKProfiles module.
    # It assumes and uses the client information which is the attribute value of client_info of profile class of PayPalSDKProfiles module.
    # It will also work behind a proxy server. If the calls need be to made via a proxy sever, set USE_PROXY flag to true and specify proxy server and port information in the profile class. 

    
    def call(requesth)    
    req_data= "#{hash2cgiString(requesth)}"
         if (@profile.m_use_proxy)
           if( @@pi["USER"].nil? || @@pi["PASSWORD"].nil? )
              http = Net::HTTP::Proxy(@@pi["ADDRESS"],@@pi["PORT"]).new(@@ep["serverURL"], @@pi["PORT"])
           else 
              http = Net::HTTP::Proxy(@@pi["ADDRESS"],@@pi["PORT"],@@pi["USER"], @@pi["PASSWORD"]).new(@@ep["SERVER"], @@pi["PORT"])
           end        
         else 
            http = Net::HTTP.new(@@ep["SERVER"], @@ep["PORT"])                                           
        end       
          
      http.verify_mode    = OpenSSL::SSL::VERIFY_NONE #unless ssl_strict
      http.use_ssl = true;        
      maskedrequest = mask_data(req_data)
    
      @@PayPalLog = Logger.new('log\PayPal.log')
      @@PayPalLog.info "\n"
      @@PayPalLog.info "#{Time.now.strftime("%a %m/%d/%y %H:%M %Z")}- SENT:"
      @@PayPalLog.info "#{CGI.unescape(maskedrequest)}"

      contents,unparseddata = http.post2(@@ep["SERVICE"],req_data,@@headers)   
      @@PayPalLog.info "\n"
      @@PayPalLog.info "#{Time.now.strftime("%a %m/%d/%y %H:%M %Z")}- RECEIVED:"
      @@PayPalLog.info "#{CGI.unescape(unparseddata)}"   

      data = CGI::parse(unparseddata)        
      transaction = Transaction.new(data)         
    end    
  end
  # Wrapper class to wrap response hash from PayPal as an object and to provide nice helper methods
  class Transaction       
    def initialize(data)
     @success = data["responseEnvelope.ack"].to_s != "Failure"
     @response = data   
   end
    def success?
      @success
    end
    def response
      @response
    end
  end
end  

