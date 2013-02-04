require 'spec_helper'
require 'integration_helper'

describe 'Groups' do

  describe 'index page' do
    describe 'group sidebar' do
      it 'does not display project groups when user has none' do
        user = Factory :user
        group = Factory :group, admin_user: user
        # project is not in the group we created
        project = Factory :project, user: user

        login_as user

        visit groups_index_path
        expect(page).to_not have_content 'You have projects in'
      end

      it 'does not display admin groups when user has none' do
        user = Factory :user
        group = Factory :group
        project = Factory :project, user: user
        project.groups << group

        login_as user

        visit groups_index_path
        expect(page).to_not have_content 'Groups you own'
      end

      it 'displays project groups when user has some' do
        user = Factory :user
        group = Factory :group
        project = Factory :project, user: user
        project.groups << group

        login_as user

        visit groups_index_path
        expect(page).to have_content 'You have projects in'
      end

      it 'displays admin groups when user has some' do
        user = Factory :user
        group = Factory :group, admin_user: user
        # Other user's project
        project = Factory :project
        project.groups << group

        login_as user

        visit groups_index_path
        expect(page).to have_content 'Groups you own'
      end

      it 'does not display group twice when user has two projects in a group' do
        user = Factory :user
        group = Factory :group
        projects = 2.times.map do
          project = Factory :project, user: user
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
