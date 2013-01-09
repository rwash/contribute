def run_valid_multi_token_test(expected)
  result = Amazon::FPS::AmazonValidator.valid_multi_token_response?(@url, @session, @params)

  result.should equal(expected)
end

def run_valid_recipient_test(expected)
  result = Amazon::FPS::AmazonValidator.valid_recipient_response?(@url, @session, @params)

  result.should equal(expected)
end

def run_valid_transaction_status_test(expected)
  result = Amazon::FPS::AmazonValidator.valid_transaction_status_response?(@response)

  result.should equal(expected)
end

def run_valid_cancel_status_test(expected)
  result = Amazon::FPS::AmazonValidator.get_cancel_status(@response)

  result.should equal(expected)
end

def  run_get_pay_status_test(response, expected)
  result = Amazon::FPS::AmazonValidator.get_pay_status(response)

  result.should equal(expected)
end

def run_get_error_test(expected)
  result = Amazon::FPS::AmazonValidator.get_error(@response)

  result.error.should == expected.error
end

