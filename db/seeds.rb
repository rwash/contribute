Category.delete_all

Category.create(short_description: 'Music',
	long_description: 'This category is dedicated for written compositions',
	created_at: '1/25/2012',
	updated_at: '1/26/2012')

Category.create(short_description: 'Movie',
	long_description: 'This category is dedicated for film productions',
	created_at: '1/25/2012',
	updated_at: '1/26/2012')

AmazonError.delete_all

AmazonError.create(error: 'AccessFailure',
	description: 'Account cannot be accessed.',
	message: 'Your account cannot be accessed.',
	retriable: 1,
	email_user: 1,
	email_admin: 0)

AmazonError.create(error: 'AccountClosed',
	description: 'Account is not active.',
	message: 'Your account is closed',
	retriable: 1,
	email_user: 1,
	email_admin: 0)

AmazonError.create(error: 'AccountLimitsExceeded',
	description: 'The spending or receiving limit on the account is exceeded. This error can also occur when the specified bank account has not yet been verified.',
	message: 'You have exceeded your spending or receiving limits. You can view your current limits at http://payments.amazon.com/sdui/sdui/viewlimits. You can upgrade these limits by adding and verifying a bank account as a payment method. Please visit Adding and Verifying Bank Accounts to learn how to add and instantly verify a bank account.',
	retriable: 1,
	email_user: 1,
	email_admin: 0)

AmazonError.create(error: 'AmountOutOfRange',
	description: 'The transaction amount is more than the allowed range.',
	message: 'Ensure that you pass an amount within the allowed range. The transaction amount in a Pay operation using credit card or bank account must be greater than $0.01.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'AuthFailure',	
	description: 'AWS was not able to validate the provided access credentials.',
	message: 'Please make sure that your AWS developer account is signed up for FPS.',
	retriable: 1,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'ConcurrentModification',
	description: 'A retriable error can happen when two processes try to modify the same data at the same time.',
	message: 'The developer should retry the request if this error is encountered.',
	retriable: 1,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'DuplicateRequest',
	description: 'A different request associated with this caller reference already exists.',
	message: 'You have used the same caller reference in an earlier request. Ensure that you use unique caller references for every new request.  Even if your earlier request resulted in an error, you should still use a unique caller reference with every request and avoid this error.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)


AmazonError.create(error: 'IncompatibleTokens',
	description: 'The transaction could not be completed because the tokens have incompatible payment instructions.',
	message: 'An error occured with your contribution.  As such, it may be caused by a number of reasons, for example:\n\n' +
		'One or more tokens has expired.\n' +
		'The recipient specified in the token is different from the actual recipient in the transaction.\n' +
		'There is violation on the amount restriction.\n' +
		'This token cannot be used with your application as another application has installed it.\n',
	retriable: 0,
	email_user: 1,
	email_admin: 1)		
		
AmazonError.create(error: 'InsufficientBalance',
	description: 'The sender, caller, or recipient\'s account balance has insufficient funds to complete the transaction.',
	message: 'Your account balance has insufficient funds to complete your transaction for this contribution.',
	retriable: 1,
	email_user: 1,
	email_admin: 0)

AmazonError.create(error: 'InternalError',
	description: 'A retriable error that happens due to some transient problem in the system.',
	message: 'The caller should retry the API call if this error is encountered.',
	retriable: 1,
	email_user: 0,
	email_admin: 0)
	
AmazonError.create(error: 'InvalidAccountState_Caller',
	description: 'The developer account cannot participate in the transaction.',
	message: 'Your account is not active. Contact your AWS Representative for more information.',
	retriable: 1,
	email_user: 0,
	email_admin: 1)
	
AmazonError.create(error: 'InvalidAccountState_Recipient',
	description: 'Recipient account cannot participate in the transaction.',
	message: 'The project owner\'s Amazon Payments account is not active. Please visit http:// payments.amazon.com for more details.',
	retriable: 1,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'InvalidAccountState_Sender',
	description: 'Sender account cannot participate in the transaction.',
	message: 'Your Amazon Payments account is not active. Please visit http://payments.amazon.com for more details.',
	retriable: 1,
	email_user: 1,
	email_admin: 0)

AmazonError.create(error: 'InvalidClientTokenId',
	description: 'The AWS Access Key Id you provided does not exist in our records.',
	message: 'Please check that the AWS Access Key Id used to make the request is valid.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'InvalidParams',
	description: 'One or more parameters in the request is invalid.',
	message: 'This contribution returned an \'InvalidParams\' error.  For more information, see the parameter descriptions for the action in the API Reference. Parameters are case sensitive.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)
	
AmazonError.create(error: 'InvalidTokenId',
	description: 'You did not install the token that you are trying to cancel.',
	message: 'You do not have permission to cancel this token. You can cancel only the tokens that you own.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'InvalidTokenId_Recipient',
	description: 'The recipient token specified is either invalid or canceled.',
	message: 'You must install a new token if you are the recipient. If you are not the recipient, get a new payment authorization from the recipient.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'InvalidTokenId_Sender',
	description: 'The send token specified is either invalid or canceled or the token is not active.',
	message: 'You must ask your customer to set up a new payment authorization.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'NotMarketplaceApp',	
	description: 'This is not an marketplace application or the caller does not match either the sender or the recipient.',
	message: 'Please check that you are specifying the correct tokens.',
	retriable: 1,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'PaymentMethodNotDefined',	
	description: 'An attempt has been made to fund the prepaid instrument at a level greater than its recharge limit.',
	message: 'Payment method is not defined in the transaction.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'SameSenderAndRecipient',	
	description: 'The sender and receiver are identical, which is not allowed.',
	message: 'This is not retriable',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'SameTokenIdUsedMultipleTimes',
	description: 'This token is already used in earlier transactions.',
	message: 'The tokens used in a transaction should be unique.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)
	
AmazonError.create(error: 'SignatureDoesNotMatch',
	description: 'The request signature calculated by Amazon does not match the signature you provided.',
	message: 'Check your AWS Secret Access Key and signing method.  For more information, see "Working with Signatures" in the Amazon Flexible Payments Service Getting Started Guide.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'TokenAccessDenied',
	description: 'Permission is denied to cancel the token.',
	message: 'You are not allowed to cancel this token.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'TokenNotActive_Recipient',
	description: 'The recipient token is canceled.',
	message: 'If you are the recipient, set up a new recipient token using the InstallPaymentInstruction operation or direct your customers to the Recipient Token Installation Pipeline to set up recipient token.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'TokenNotActive_Sender',
	description: 'The sender token is canceled.',
	message: 'You must ask your customer to set up a new payment authorization because the current authorization is not active.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'TokenUsageError',	
	description: 'The token usage limit is exceeded.',
	message: 'If the usage has exceeded for this period, then wait for the next period before making another transaction. If the usage has exceeded for the entire authorization period, then ask your customer to set up a new payment authorization.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)
	
AmazonError.create(error: 'TransactionDenied',
	description: 'This transaction is not allowed.',
	message: 'You are not allowed to do this transaction. Check your credentials.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'UnverifiedAccount_Recipient',
	description: 'The recipient\'s account must have a verified bank account or a credit card before this transaction can be initiated.',
	message: 'The recipient\'s Amazon Payments account is not active. Please visit http://payments.amazon.com for more details.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)
	
AmazonError.create(error: 'UnverifiedAccount_Sender',
	description: 'The sender\'s account must have a verified U.S. credit card or a verified U.S bank account before this transaction can be initiated.',
	message: 'Please add a U.S. credit card or U.S. bank account and verify your bank account before making this payment.',
	retriable: 0,
	email_user: 1,
	email_admin: 0)

AmazonError.create(error: 'UnverifiedBankAccount',
	description: 'A verified bank account should be used for this transaction.',
	message: 'Visit the http://payments.amazon.com web site to verify your bank account.',
	retriable: 0,
	email_user: 1,
	email_admin: 0)

AmazonError.create(error: 'UnverifiedEmailAddress_Caller',
	description: 'The caller account must have a verified email address.',
	message: 'You cannot make a web service API call without verifying your email address. Go to http://payments.amazon.com web site and make payments.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)

AmazonError.create(error: 'UnverifiedEmailAddress_Recipient',
	description: 'The recipient account must have a verified email address for receiving payments.',
	message: 'The project owner cannot receive payments. Please tell the owner to visit http://payments.amazon.com to verify their account and receive payments.',
	retriable: 0,
	email_user: 0,
	email_admin: 1)
	
AmazonError.create(error: 'UnverifiedEmailAddress_Sender',
	description: 'The sender account must have a verified email address for this payment',
	message: 'You cannot send payments. Please verify your email address. Go to http://payments.amazon.com to verify your account and send payments.',
	retriable: 0,
	email_user: 1,
	email_admin: 0)

ContributionStatus.delete_all

ContributionStatus.create(id: 1, name: 'None')
ContributionStatus.create(id: 2, name: 'Success')
ContributionStatus.create(id: 3, name: 'Pending')
ContributionStatus.create(id: 4, name: 'Failed')
ContributionStatus.create(id: 5, name: 'Cancelled')
ContributionStatus.create(id: 6, name: 'Retry_Pay')
ContributionStatus.create(id: 7, name: 'Retry_Cancel')
