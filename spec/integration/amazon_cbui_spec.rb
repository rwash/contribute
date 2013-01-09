require 'spec_helper'
require 'integration_helper'

class AmazonCbuiTesting
  describe 'amazon process' do
    fixtures :users

    before :all do
      Capybara.default_driver = :selenium

      @headless = Headless.new
      @headless.start
    end

    after :all do
      Project.delete_all
      Contribution.delete_all
    end

    it "recipient request should direct to amazon login" do
      request = Amazon::FPS::RecipientRequest.new(save_project_url)
      visit(request.url)

      page.should have_content('Sign in with your Amazon account')
    end

    #if you receive a not well formed :[recipientTokenList] update the project factor
    it "multi token request should direct to amazon login" do
      @project = FactoryGirl.create(:project)
      @contribution = FactoryGirl.create(:contribution)

      session = {}
      session[:contribution] = @contribution

      request = Amazon::FPS::MultiTokenRequest.new(session, save_contribution_url, @project.payment_account_id, @contribution.amount, @project.name)

      visit request.url
      page.should have_content('Sign in with your Amazon account')
    end
  end
end
