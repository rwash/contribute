# === Attributes
#
# * *description* (+string+)
# * *message* (+text+)
# * *retriable* (+boolean+)
# * *email_user* (+boolean+)
# * *email_admin* (+boolean+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *error* (+string+)
class AmazonError < ActiveRecord::Base
	UNKNOWN = 'Unknown Error'
	def self.unknown_error(error)
		return AmazonError.new(:error => UNKNOWN,
			:description => 'Amazon returned an error that we currently do not handle',
			:message => "Please look up the error code '#{error}' at http://docs.amazonwebservices.com/AmazonFPS/latest/FPSAdvancedGuide/APIErrorCodesTable.html and add the appropriate record in the amazon_errors table.",
			:retriable => 0,
			:email_user => 0,
			:email_admin => 1)
	end
end
