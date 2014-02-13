require 'spec_helper'
require 'integration_helper'

feature 'updates' do
  scenario 'User creates an update' do
    project = create :active_project
    update = build :update
    login_as project.owner

    visit project_path project
    click_on "Add an update"
    fill_in :title, with: update.title
    fill_in :update_content, with: update.content
    click_on "Post Update"

    page.should have_content update.content
  end
end
