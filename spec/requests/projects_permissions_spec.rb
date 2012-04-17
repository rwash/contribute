require 'spec_helper'
require 'requests_helper'

describe 'Project permissions' do

	describe 'permissions' do
		context 'user is not signed in' do
			before(:all) do
				@user = FactoryGirl.create(:user)
			end

			after(:all) do
				@user.delete
			end

			it "can view project" do
				project = FactoryGirl.create(:project, :user_id => @user.id)
				visit project_path(project)
				assert_equal project_path(project), current_path
				project.delete
			end
			it "can't view inactive project" do
				project = FactoryGirl.create(:project, :active => false, :user_id => @user.id)
				visit project_path(project)
				assert_equal root_path, current_path
				project.destroy
			end
			it "can't create a project" do
				visit new_project_path
				#new_user_session_path is the login page
				assert_equal new_user_session_path, current_path
			end
			it "can't destroy a project" do
				project = FactoryGirl.create(:project, :user_id => @user.id)
				visit project_path(project)
				expect { click_button("Delete Project") }.should raise_error
				project.destroy
			end
		end

# TODO: I would love for these to work as integration tests as well as controller tests
# but I just can't get the sign_in request helper to work.
#		context 'user is signed in' do
#			before(:all) do
#				@user = FactoryGirl.create(:user)
#				@user.confirm!
#			end
#
#			after(:all) do
#				@user.delete
#			end
#			it 'can create a project' do
#				sign_in @user
#				visit new_project_path
#				assert_equal new_project_path, current_path
#			end
#			it "can't destroy a project they don't own" do
#				project = FactoryGirl.create(:project, user_id: @user.id + 1)
#				sign_in @user
#				visit project_path(project)
#				# No button to delete
#				project.destroy
#			end
#			it "can destroy a project they do own" do
#				project = FactoryGirl.create(:project, user_id: @user.id)
#				sign_in @user
#				visit project_path(project)
#				click_button "Delete Project"
#				assert_equal root_path, current_path
#				# Flash says success
#				project.destroy
#			end
#		end
	end
end
