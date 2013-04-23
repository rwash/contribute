require 'spec_helper'
require 'integration_helper'

feature 'Sign in', :focus do
  before :all do
    Capybara.default_driver = :selenium

    @headless = Headless.new
    @headless.start
  end

  context 'with regular user' do
    let(:user) { create :user }

    scenario 'signs in successfully' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'

      expect(current_path).to eq root_path
      expect(page).to have_content 'Signed in successfully'
    end
  end

  context 'with blocked user' do
    let(:user) { create :user, blocked: true }

    scenario 'prevents sign in' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'

      expect(page).to have_content 'Your account has been blocked'
      expect(current_path).to eq new_user_session_path
    end
  end
end
