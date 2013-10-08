require 'spec_helper'

feature 'Search' do
  context 'with no projects' do
    it 'displays an appropriate message' do
      search_for search_term
      page.should have_content 'no projects were found'
    end
  end

  scenario 'without searching projects index does not display search error' do
    visit projects_path
    page.should_not have_content 'no projects were found'
  end

  context 'with a single matching active project' do
    let!(:matching_project) { create :active_project, name: search_term }

    it 'displays information for the matching project' do
      search_for search_term
      page.should have_content matching_project.name
      page.should have_content matching_project.short_description
    end
  end

  context 'with a project that is not publicly viewable' do
    let!(:matching_project) { create :project, name: search_term }

    it 'does not present the matching project' do
      search_for search_term
      page.should_not have_content matching_project.short_description
    end
  end

  private
  def search_for query
    visit projects_path
    fill_in 'search', with: query
    click_button 'Search'
  end

  def search_term
    'unicorn'
  end
end
