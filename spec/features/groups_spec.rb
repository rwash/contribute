require 'spec_helper'
require 'integration_helper'

feature 'Groups' do

  describe 'index page' do
    # TODO use let() to reduce the number of records we're creating here
    describe 'group sidebar' do
      scenario 'does not display project groups when user has none' do
        user = create :user
        group = create :group, owner: user
        # project is not in the group we created
        project = create :project, owner: user

        login_as user

        visit groups_index_path
        expect(page).to_not have_content 'You have projects in'
      end

      scenario 'does not display admin groups when user has none' do
        user = create :user
        group = create :group
        project = create :project, owner: user
        project.groups << group

        login_as user

        visit groups_index_path
        expect(page).to_not have_content 'Groups you own'
      end

      scenario 'displays project groups when user has some' do
        user = create :user
        group = create :group
        project = create :project, owner: user
        project.groups << group

        login_as user

        visit groups_index_path
        expect(page).to have_content 'You have projects in'
      end

      scenario 'displays admin groups when user has some' do
        user = create :user
        group = create :group, owner: user
        # Other user's project
        project = create :project
        project.groups << group

        login_as user

        visit groups_index_path
        expect(page).to have_content 'Groups you own'
      end

      scenario 'does not display group twice when user has two projects in a group' do
        user = create :user
        group = create :group
        projects = 2.times.map do
          project = create :project, owner: user
          project.groups.push group
          project
        end

        login_as user

        visit groups_index_path
        # Group name should appear exactly once on the page
        expect(page.all('#sidebar a', text: group.name).count).to eq 1
      end
    end
  end
end
