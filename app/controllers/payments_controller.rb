require 'cgi'
require 'profile'
require 'caller'

class PaymentsController < ApplicationController
   @@profile = PayPalSDKProfiles::Profile
   @@ep=@@profile.endpoints
   @@clientDetails=@@profile.client_details

	def set_preapproval
    @host=request.host.to_s
    @port=request.port.to_s  
		@cancelURL="http://#{@host}:#{@port}#cancelYo"
    @returnURL="http://#{@host}:#{@port}#greatSuccess"   
    
    @@ep["SERVICE"]="/AdaptivePayments/Preapproval" 
    @caller =  PayPalSDKCallers::Caller.new(false)
    @transaction = @caller.call(
    {
      "requestEnvelope.errorLanguage" => "en_US",
      "clientDetails.ipAddress"=>@@clientDetails["ipAddress"],
      "clientDetails.deviceId" =>@@clientDetails["deviceId"],
      "clientDetails.applicationId" => @@clientDetails["applicationId"],
      "returnUrl" =>@returnURL,
      "cancelUrl"=>@cancelURL,
      "currencyCode"=>"USD", #params[:setpreapproval][:currency],
      "startingDate" =>"2012-02-29", #params[:startDate],
      "endingDate" =>"2012-06-12", #params[:endDate],
      "maxNumberOfPayments" =>"1", # params[:maxNumberOfPayments],
      "maxTotalAmountOfAllPayments" =>"50.0", # params[:maxTotalAmountOfAllPayments],
      "requestEnvelope.senderEmail"=>"androck1@gmail.com" #params[:email]
    }
    )  
		if (@transaction.success?)
        session[:setpreapproval_response]=@transaction.response   
        @response = session[:setpreapproval_response]
        @preapprovalkey=@response["preapprovalKey"]        

				urlPreapprovalKey = @preapprovalkey.to_s[2..-3] #trim off the brackets and quotes
        redirect_to "https://www.sandbox.paypal.com/webscr?cmd=_ap-preapproval&preapprovalkey=#{urlPreapprovalKey}"
  	else
		 flash[:alert] = 'An error occured with the payment. Please try again.'
     logger.error @transaction.response
     session[:paypal_error]=@transaction.response
     redirect_to root_path
  	end
  	rescue Errno::ENOENT => exception
		 	flash[:alert] = 'An error occured with the payment. Please try again.'
			logger.error exception
    	redirect_to root_path
	end

	def create_pay
    @host=request.host.to_s
    @port=request.port.to_s   
    @cancelURL="http://#{@host}:#{@port}#cancelled"
    @returnURL="http://#{@host}:#{@port}#success"
    @@ep["SERVICE"]="/AdaptivePayments/Pay" 
    @caller =  PayPalSDKCallers::Caller.new(false)
        #Generating request string
    req ={
       "requestEnvelope.errorLanguage" => "en_US",
       "clientDetails.ipAddress"=>@@clientDetails["ipAddress"],
       "clientDetails.deviceId" =>@@clientDetails["deviceId"],
       "clientDetails.applicationId" => @@clientDetails["applicationId"],
       "receiverList.receiver[0].email"=>"seller_1330462024_biz@msu.edu",
       "receiverList.receiver[0].amount"=>"50.00",
       "currencyCode"=>"USD",
       "actionType"=>"CREATE",
       "returnUrl" =>@returnURL,
       "cancelUrl"=>@cancelURL
     }
    #sending the request string to call method where the PAY API call is made
      @transaction = @caller.call(req)
     if (@transaction.success?)
        session[:createpay_response]=@transaction.response   
        @response = session[:createpay_response]
				@paykey = @response["payKey"]
        @paymentExecStatus=@response["paymentExecStatus"].to_s[2..-3] 
        if (@paymentExecStatus.to_s=="CREATED")
					urlPayKey = @paykey.to_s[2..-3] #trim off the brackets and quotes
					logger.info "Redirect time!"
					redirect_to "https://www.sandbox.paypal.com/webscr?cmd=_ap-payment&paykey=#{urlPayKey}"
				else
		 			flash[:alert] = 'An error occured with the payment. Please try again.'
     			redirect_to root_path
        end
   else
		 flash[:alert] = 'An error occured with the payment. Please try again.'
     logger.error @transaction.response
     session[:paypal_error]=@transaction.response
     redirect_to root_path
   end
  rescue Errno::ENOENT => exception
		flash[:alert] = 'An error occured with the payment. Please try again.'
		logger.error exception
    redirect_to root_path
 end
end
