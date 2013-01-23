require 'spec_helper'
require 'requests_helper'

describe 'Project permissions' do
  before(:all) do
    @headless = Headless.new
    @headless.start
  end

  after(:all) do
    @headless.destroy
  end

  describe 'permissions' do
    context 'when user is not signed in' do
      let(:user) { Factory :user }

      after(:all) do
        user.delete
      end

      it "can view active project" do
        project = FactoryGirl.create(:project, :user => user, :state => "active")
        visit project_path(project)
        expect(current_path).to eq project_path(project)
        project.delete
      end
      it "can not view inactive project" do
        project = FactoryGirl.create(:project, :user => user, :state => "inactive")
        visit project_path(project)
        expect(current_path).to_not eq project_path(project)
        project.destroy
      end
      it "can't create a project" do
        visit new_project_path
        # new_user_session_path is the login page
        expect(current_path).to eq new_user_session_path
      end
      it "can't destroy a project" do
        project = FactoryGirl.create(:project, :user => user)
        visit project_path(project)
        expect { click_button("Delete Project") }.to raise_error
        project.destroy
      end
    end

# TODO: I would love for these to work as integration tests as well as controller tests
# but I just can't get the sign_in request helper to work.
#    context 'user is signed in' do
#      before(:all) do
#        @user = FactoryGirl.create(:user)
#        @user.confirm!
#      end
#
#      after(:all) do
#        @user.delete
#      end
#      it 'can create a project' do
#        sign_in @user
#        visit new_project_path
#        assert_equal new_project_path, current_path
#      end
#      it "can't destroy a project they don't own" do
#        project = FactoryGirl.create(:project)
#        sign_in @user
#        visit project_path(project)
#        # No button to delete
#        project.destroy
#      end
#      it "can destroy a project they do own" do
#        project = FactoryGirl.create(:project, user: @user)
#        sign_in @user
#        visit project_path(project)
#        click_button "Delete Project"
#        assert_equal root_path, current_path
#        # Flash says success
#        project.destroy
#      end
#    end
  end
end
