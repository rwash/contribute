class Logging::LogPayRequest < ActiveRecord::Base
	has_one :log_pay_response
	has_many :log_errors
end
