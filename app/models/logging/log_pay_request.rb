# === Attributes
#
# * *CallerReference* (+string+)
# * *RecipientTokenId* (+string+)
# * *SenderTokenId* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
class Logging::LogPayRequest < ActiveRecord::Base
	has_one :log_pay_response
	has_many :log_errors
end
