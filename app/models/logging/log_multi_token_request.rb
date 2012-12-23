# === Attributes
#
# * *callerReference* (+string+)
# * *recipientTokenList* (+string+)
# * *globalAmountLimit* (+integer+)
# * *paymentReason* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
class Logging::LogMultiTokenRequest < ActiveRecord::Base
	has_one :log_multi_token_response
end
