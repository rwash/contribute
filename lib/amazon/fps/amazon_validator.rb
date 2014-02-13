require 'amazon/fps/signatureutilsforoutbound'

module Amazon
  module FPS
    class AmazonValidator

	#if the contribution in the session controller is not available, there is no tokenID returned, the status code was not successful, or the signature could not be verfied	
	def self.valid_multi_token_response?(url, session, params)
		return (!params["tokenID"].nil? and valid_multi_token_status?(params["status"]) and valid_cbui_response?(params, url))
	end

    def self.valid_recipient_response?(url, session, params)
      project = params[:project_id]
      token = params["tokenID"]
      correct_status = params['status'] == "SR"

      project && token && correct_status && valid_cbui_response?(params, url)
    end

	def self.get_transaction_status(response)
		response['GetTransactionStatusResult']['TransactionStatus'].downcase.to_sym
	end

	#Written under the assumption that if a transaction returns failure, it WILL contain an error
	def self.get_error(response)
		if response['Errors'].nil? or response['Errors']['Error'].nil? or response['Errors']['Error']['Code'].nil?
      raise "Could not parse amazon error"
		end

		error_code = response['Errors']['Error']['Code']
		error = AmazonError.find_by_error(error_code)
		if error.nil?
			error = AmazonError.unknown_error(error_code)
		end

		return error
	end

      protected
      #this verifies that the signature returned came from amazon
      def self.valid_cbui_response?(params, url_end_point)
        utils = Amazon::FPS::SignatureUtilsForOutbound.new

        #This is rails garbage we don't need to send to amazon
        params.delete("controller")
        params.delete("action")
        params.delete(:project_id)

        # TODO investigate that 'GET'
        utils.validate_request(parameters: params, url_end_point: url_end_point, http_method: "GET")
      end

      #these are acceptable status codes for the payment method
      def self.valid_multi_token_status?(status)
        return (status == "SA" or status == "SB" or status == "SC")
      end
    end

  end
end
