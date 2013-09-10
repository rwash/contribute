require 'spec_helper'
require 'integration_helper'

feature 'amazon process', :js do

  scenario "recipient request should direct to amazon login" do
    request = Amazon::FPS::RecipientRequest.new(save_project_url)
    visit(request.url)

    expect(page).to have_content I18n.t(:amazon_sign_in)
  end

  #if you receive a not well formed :[recipientTokenList] update the project factory
  scenario "multi token request should direct to amazon login" do
    @project = create(:active_project)
    @contribution = create(:contribution)

    session = {}
    session[:contribution] = @contribution

    request = Amazon::FPS::MultiTokenRequest.new(session, save_contribution_url, @project.payment_account_id, @contribution.amount, @project.name)

    visit request.url
    expect(page).to have_content I18n.t(:amazon_sign_in)
  end
end
