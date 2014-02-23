require 'spec_helper'
require 'integration_helper'

feature 'Projects', :js do

  let!(:projects) { 4.times.map { create :active_project } }

  scenario 'creation' do
    project = build(:project)
    user = create :user

    #login with our project creator
    login_as user

    #create a project
    visit(new_project_path)

    #fill in form
    fill_in 'name' , with: project.name
    fill_in 'project_funding_goal', with: project.funding_goal
    fill_in 'DatePickerEndDate', with: project.end_date.strftime('%Y-%m-%d')
    fill_in 'project_short_description', with: project.short_description
    fill_in_ckeditor 'project_long_description', with: 'This is my message!'

    click_button 'Create Project'

    page.should have_button 'Connect an Amazon account'
  end
end
