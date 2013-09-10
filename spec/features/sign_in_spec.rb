require 'spec_helper'
require 'integration_helper'

feature 'Sign in', :js do

  context 'with regular user' do
    let(:user) { create :user }

    scenario 'signs in successfully' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'

      expect(current_path).to eq root_path
      expect(page).to have_content I18n.t(:signed_in)
    end
  end

  context 'with blocked user' do
    let(:user) { create :user, blocked: true }

    scenario 'prevents sign in' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'

      expect(page).to have_content I18n.t(:account_blocked)
      expect(current_path).to eq new_user_session_path
    end
  end
end
