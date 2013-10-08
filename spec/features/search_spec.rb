require 'spec_helper'

feature 'Search' do
  scenario 'searching with no projects' do
    visit projects_path
    fill_in 'search', with: 'Unicorn'
    click_button 'Search'
    page.should have_content 'no projects were found'
  end
end
