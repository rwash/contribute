# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :retriable, class: AmazonError do
		error 'InternalError'
		description 'A retriable error that happens due to some transient problem in the system.'
		message 'The caller should retry the API call if this error is encountered.'
		retriable true
		email_user false
		email_admin false
  end
	
	factory :email_user, class: AmazonError do
		error 'UnverifiedAccount_Sender'
		description 'The sender\'s account must have a verified U.S. credit card or a verified U.S bank account before this transaction can be initiated.'
		message 'Please add a U.S. credit card or U.S. bank account and verify your bank account before making this payment.'
		retriable false
		email_user true
		email_admin false
	end

	factory :email_admin, class: AmazonError do
		error 'UnverifiedAccount_Recipient'
		description 'The recipient\'s account must have a verified bank account or a credit card before this transaction can be initiated.'
		message 'The recipient\'s Amazon Payments account is not active. Please visit http://payments.amazon.com for more details.'
		retriable false
		email_user false
		email_admin true
	end

	factory :email_both, class: AmazonError do
		error 'IncompatibleTokens'
		description 'The transaction could not be completed because the tokens have incompatible payment instructions.'
		message 'An error occured with your contribution.  As such, it may be caused by a number of reasons, for example:\n\n One or more tokens has expired.\n The recipient specified in the token is different from the actual recipient in the transaction.\n There is violation on the amount restriction.\n This token cannot be used with your application as another application has installed it.\n'
		retriable false
		email_user true
		email_admin true
	end
end
