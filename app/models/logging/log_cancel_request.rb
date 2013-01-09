# === Attributes
#
# * *TokenId* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
class Logging::LogCancelRequest < ActiveRecord::Base
  has_one :log_cancel_response
  has_many :log_errors
end
