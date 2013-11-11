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

    page.should have_content 'Unconfirmed'
    page.should have_button 'Connect an Amazon account'
  end

  # TODO this should be tested at the controller level, not the feature level
  describe 'blocking process' do
    let(:admin) { create :user, admin: true }
    before { login_as admin }

    context 'starting with unconfirmed project' do
      let(:project) { create :project, state: :unconfirmed }

      scenario "should set the project state to 'unconfirmed'" do
        block_project
        unblock_project
        expect(project.reload.state).to eq :unconfirmed
      end
    end

    context 'starting with inactive project' do
      let(:project) { create :active_project, state: :inactive }

      scenario "should set the project state to 'inactive'" do
        block_project
        unblock_project
        expect(project.reload.state).to eq :inactive
      end
    end

    context 'starting with active project' do
      let(:project) { create :active_project }

      scenario "should set the project state to 'inactive'" do
        block_project
        unblock_project
        expect(project.reload.state).to eq :inactive
      end
    end

    private
    def block_project
      visit project_path(project)
      click_button 'Block Project'
      expect(page).to have_content 'Successfully blocked'
    end

    def unblock_project
      click_button 'Unblock Project'
      expect(page).to have_content 'Successfully unblocked'
    end
  end
end
