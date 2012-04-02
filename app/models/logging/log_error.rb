class Logging::LogError < ActiveRecord::Base
	belongs_to :log_pay_request, :foreign_key => "log_request_id"
	#belongs_to :log_cancel_request, :foreign_key => "request_id"
end
