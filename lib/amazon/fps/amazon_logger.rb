module Amazon
module FPS

class AmazonLogger
	def self.log_multi_token_request(params)
		log = Logging::LogMultiTokenRequest.new
		save_record(log, params)
	end

	def self.log_multi_token_response(params)
		log = Logging::LogMultiTokenResponse.new
		save_record(log, params)
	end

	def self.log_recipient_token_response(params)
		log = Logging::LogRecipientTokenResponse.new
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
