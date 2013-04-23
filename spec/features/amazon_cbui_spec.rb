require 'spec_helper'
require 'integration_helper'

feature 'amazon process', :focus do
  before :all do
    Capybara.default_driver = :selenium

    @headless = Headless.new
    @headless.start
  end

  scenario "recipient request should direct to amazon login" do
    request = Amazon::FPS::RecipientRequest.new(save_project_url)
    visit(request.url)

    expect(page).to have_content('Sign in with your Amazon account')
  end

  #if you receive a not well formed :[recipientTokenList] update the project factor
  scenario "multi token request should direct to amazon login" do
    @project = create(:project)
    @contribution = create(:contribution)

    session = {}
    session[:contribution] = @contribution

    request = Amazon::FPS::MultiTokenRequest.new(session, save_contribution_url, @project.payment_account_id, @contribution.amount, @project.name)

    visit request.url
    expect(page).to have_content('Sign in with your Amazon account')
  end
end
