require 'spec_helper'

feature 'Search' do
  context 'with no projects' do
    it 'displays an appropriate message' do
      search_for 'Unicorn'
      page.should have_content 'no projects were found'
    end
  end

  scenario 'without searching projects index does not display search error' do
    visit projects_path
    page.should_not have_content 'no projects were found'
  end

  private
  def search_for query
    visit projects_path
    fill_in 'search', with: query
    click_button 'Search'
  end
end
