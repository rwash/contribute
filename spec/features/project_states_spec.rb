require 'spec_helper'
require 'integration_helper'

feature 'amazon process', :js do

  describe 'project' do
    scenario "create successfully" do
      project = build(:project)
      user = create :user

      #login with our project creator
      login_as user

      #create a project
      visit(new_project_path)
      expect(current_path).to eq new_project_path

      #fill in form
      fill_in 'name' , with: project.name
      fill_in 'project_funding_goal', with: project.funding_goal
      fill_in 'DatePickerEndDate', with: project.end_date.strftime('%m/%d/%Y')
      fill_in 'project_short_description', with: project.short_description
      fill_in_ckeditor 'project_long_description', with: 'This is my message!'

      click_button 'Create Project'

      visit(project_path(project))
      get_and_assert_project(project.name)
      #project is now unconfirmed

      click_button 'Edit Project'
      expect(page).to have_content 'Amazon Payments'

      click_button 'Update Project'
      expect(page).to have_content 'Sign in with your Amazon account'
      login_amazon 'spartanfan10@hotmail.com', 'testing'
      click_amazon_continue
      find('a').click
      expect(page).to have_content 'Project saved successfully'
      #project is no inactive

      click_button('Activate')
      page.driver.accept_js_prompts!
      expect(page).to have_content 'Successfully activated project.'
      #project is now active

      visit(project_path(project))
      click_button 'Cancel Project'
      page.driver.accept_js_prompts!
      expect(page).to have_content 'Project successfully cancelled.'
      #project is now cancelled

    end

  end
end
