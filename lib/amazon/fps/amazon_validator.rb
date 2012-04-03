require 'amazon/fps/signatureutilsforoutbound'

module Amazon
module FPS

#Disclaimer: ruby made me add if <expression> return true else return false; otherwise I received a void value expression?
class AmazonValidator
	#if the contribution in the session controller is not available, there is no tokenID returned, the status code was not successful, or the signature could not be verfied	
	def self.invalid_multi_token_response?(url, session, params)
		if session[:contribution].nil? or params[:tokenID].nil? or invalid_multi_token_status?(params[:status]) or !valid_cbui_response?(params, url)
			return true
		else
			return false
		end
	end

	#if the project in the session controller is not available, there is no tokenID return, the status code is not a successful one, or the signature could not be verified
	def self.invalid_recipient_response?(url, session, params)
		if session[:project].nil? or params[:tokenID].nil? or params[:status] != "SR" or !valid_cbui_response?(params, url)
			return true
		else
			return false
		end
	end

	#if the response contains errors or the transaction status was not a success
	def self.invalid_cancel_response?(response)
		return !response["Errors"].nil?
	end

	#if there was errors in the response
	def self.invalid_payment_response?(response)
		if !response["Errors"].nil?
			return true
		else
			return response["PayResult"]["TransactionStatus"] != "Success" unless response["PayResult"].nil?
		end

		return true
	end

protected
	#this verifies that the signature returned came from amazon
	def self.valid_cbui_response?(params, url_end_point)
		access_key = Rails.application.config.aws_access_key
		secret_key = Rails.application.config.aws_secret_key
		utils = Amazon::FPS::SignatureUtilsForOutbound.new(access_key, secret_key)

		#This is rails garbage we don't need to send to amazon
		params.delete("controller")
		params.delete("action")

		return utils.validate_request(:parameters => params, :url_end_point => url_end_point, :http_method => "GET")	
	end

	#these are acceptable status codes for the payment method
	def self.invalid_multi_token_status?(status)
		if status != "SA" and status != "SB" and status != "SC"
			return true
		else
			return false
		end
	end
end

end
end
