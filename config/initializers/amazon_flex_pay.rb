AmazonFlexPay.access_key = 'AKIAIVLAEPTVD6GUEKKQ'
AmazonFlexPay.secret_key = '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'

# TODO figure out why the testing keys are different
if Rails.env == 'test'
  AmazonFlexPay.access_key = 'AKIAINGLDSXXU7EG4K7Q'
  AmazonFlexPay.secret_key = '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'
end

#AmazonFlexPay.go_live! if Rails.env.production?
