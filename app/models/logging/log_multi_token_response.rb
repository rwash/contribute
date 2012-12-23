# === Attributes
#
# * *tokenID* (+string+)
# * *status* (+string+)
# * *errorMessage* (+string+)
# * *warningCode* (+string+)
# * *warningMessage* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *log_multi_token_request_id* (+integer+)
class Logging::LogMultiTokenResponse < ActiveRecord::Base
	belongs_to :log_multi_token_request
end
