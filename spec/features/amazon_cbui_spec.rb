require 'spec_helper'
require 'integration_helper'

feature 'amazon process', :js do

  scenario "recipient request should direct to amazon login" do
    return_url = project_amazon_payment_accounts_url(project, method: :get)
    request = Amazon::FPS::RecipientRequest.new(return_url)
    visit(request.url)

    expect(page).to have_content('Sign in with your Amazon account')
  end

  #if you receive a not well formed :[recipientTokenList] update the project factory
  scenario "multi token request should direct to amazon login" do
    @project = create(:active_project)
    @contribution = create(:contribution)

    session = {}
    session[:contribution] = @contribution

    visit AmazonFlexPay.multi_use_pipeline(
      UUIDTools::UUID.random_create.to_s,
      save_contribution_url,
      recipient_token_list: @project.payment_account_id,
      global_amount_limit: @contribution.amount
    )

    expect(page).to have_content('Sign in with your Amazon account')
  end

  private
  def project
    @_project ||= create :project
  end
end
