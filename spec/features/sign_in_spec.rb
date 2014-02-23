require 'spec_helper'
require 'integration_helper'

feature 'Sign in', :js do
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
