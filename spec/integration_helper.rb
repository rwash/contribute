include Warden::Test::Helpers
Warden.test_mode!

def login_amazon(email, password)
  expect(page).to have_content('Sign in with your Amazon account')

  #Now we're in amazon's sign in
  fill_in 'ap_email', with: email
  fill_in 'ap_password', with: password
  click_on 'signInSubmit'
end

def click_amazon_continue()
  find('input.submit').click #This is an image without an id or value, so we have to find it!
end

def get_and_assert_project(project_name)
  project = Project.find_by_name(project_name)
  expect(project).to_not be_nil

  return project
end

def get_and_assert_contribution(project_id)
  contribution = Contribution.find_by_project_id(project_id)
  expect(contribution).to_not be_nil

  return contribution
end

def make_amazon_payment(user, password)
  login_amazon(user, password)

  #update: if your account has different payment options, you'll need to choose which one
  #choose 'existingCard_0'
  click_amazon_continue

  #update: might have to confirm again
  click_amazon_continue
end

def generate_contribution(user, amazon_user, amazon_password, project,amount)
  #login
  #TODO move to a before filter
  login_as user

  #go to project page
  visit project_path(project)

  #contribute!
  click_button 'Contribute to this project'
  expect(current_path).to eq new_contribution_path(project)

  fill_in 'contribution_amount', with: amount
  click_button 'Make Contribution'

  pending 'Amazon is returning an SSLError'
  make_amazon_payment(amazon_user, amazon_password)

  #Calling find first, so capybara will wait until it appears
  expect(page).to have_content('Contribution submitted')
  expect(current_path).to eq project_path(project)

  contribution = Contribution.last
  expect(contribution).to_not be_nil
  expect(contribution.project).to eq(project)

  return contribution
end

#Used for amazon redirection
def get_full_url(path)
  return "http://127.0.0.1:#{Capybara.server_port}#{path}"
end

def assert_amazon_error(id)
  log_error = Logging::LogError.find_by_log_request_id(id)

  expect(log_error).to_not be_nil
  expect(log_error.Code).to_not be_nil
  expect(log_error.Message).to_not be_nil
  expect(log_error.RequestId).to_not be_nil
end

def delete_logs()
  Logging::LogCancelRequest.delete_all
  Logging::LogCancelResponse.delete_all
  Logging::LogError.delete_all
  Logging::LogGetTransactionRequest.delete_all
  Logging::LogGetTransactionResponse.delete_all
  Logging::LogMultiTokenRequest.delete_all
  Logging::LogMultiTokenResponse.delete_all
  Logging::LogPayRequest.delete_all
  Logging::LogPayResponse.delete_all
  Logging::LogRecipientTokenResponse.delete_all
end

def fill_in_ckeditor(locator, opts)
  browser = page.driver.browser
  content = opts.fetch(:with).to_json
  browser.execute_script <<-SCRIPT
    CKEDITOR.instances['#{locator}'].setData(#{content});
    $('textarea##{locator}').text(#{content});
  SCRIPT
end
