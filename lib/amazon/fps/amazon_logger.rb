module Amazon
module FPS

LOG_REQUEST_ID = 'log_request_id'

class AmazonLogger
	def self.log_multi_token_request(params, session)
		log = Logging::LogMultiTokenRequest.new
		save_record(log, params)

		session[LOG_REQUEST_ID] = log.id
	end

	def self.log_multi_token_response(params, session)
		log = Logging::LogMultiTokenResponse.new
		log.log_multi_token_request_id = session[LOG_REQUEST_ID]

		save_record(log, params)
	end

	def self.log_recipient_token_response(params)
		log = Logging::LogRecipientTokenResponse.new
		save_record(log, params)
	end

	def self.log_pay_request(params)
		log = Logging::LogPayRequest.new
		save_record(log, params)

		return log
	end
	
	def self.log_pay_response(response, request)
		if response['Errors'].nil?
			log = Logging::LogPayResponse.new
			log.log_pay_request_id = request.id
			log.RequestId = response['ResponseMetadata']['RequestId'] unless response['ResponseMetadata'].nil?

			save_record(log, response['PayResult']) unless response['PayResult'].nil?
		else
			response['Errors'].each_pair do |k, error_hash|
				log = Logging::LogError.new
				log.log_request_id = request.id
				log.RequestId = response['RequestID']

				save_record(log, error_hash)
			end
		end
	end

	def self.log_cancel_request(params)
		log = Logging::LogCancelRequest.new
		save_record(log, params)

		return log
	end

	def self.log_cancel_response(params, request)
		log = Logging::LogCancelResponse.new
		log.log_cancel_request_id = request.id

		save_record(log, params)
	end

protected
	#dynamically assign param values to record in arguments
	def self.save_record(record, params)
		stripped_params = {}
	
		params.each_pair do |k,v|
			if record.attributes.has_key?(k)
				stripped_params[k] = v
			end
		end

		#update_attributes will save to the db, if the record is not already
		record.update_attributes(stripped_params)
	end
end

end
end
