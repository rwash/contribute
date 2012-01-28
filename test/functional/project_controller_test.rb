require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

	NON_EXISTENT_PROJECT_ID = 9999

	setup do
		@project = get_valid_project(:goggles)
	end

	#SHOW TESTING
	test "show_redirect_on_invalid_id" do
		assert_equal(Project.find_by_id(NON_EXISTENT_PROJECT_ID), nil, "Project exists, test is unusable, change NON_EXISTENT_PROJECT_ID")
		get(:show, {'id' => NON_EXISTENT_PROJECT_ID})
		assert_redirected_to projects_path
		assert_equal 'Invalid Project', flash[:notice], "Flash notice did not say '\Invalid\' Project.  Did you change the message?"
	end

	test "show_on_valid_id" do
		get(:show, :id => @project.id)
		assert_response :success
	end

	#NEW TESTING
	test "new_saved_and_redirected_on_success" do
		#nuke so we can reinsert into db
		if Project.find_by_id(@project.id) != nil
			Project.destroy(@project.id)
		end

		assert_difference('Project.count') do
			post :create, project: @project.attributes
		end
		assert_redirected_to project_path(assigns(:project))
	end

	test "new_failure_on_invalid_parameters" do
		#nuke so we can reinsert into db
		if Project.find_by_id(@project.id) != nil
			Project.destroy(@project.id)
		end

		@project.fundingGoal = -1
		post :create, project: @project.attributes
		assert_response :success
		assert_select "h2", {:text => /(.*)error(.*)/}, "heading does not contain errors" 
	end

	test "update_success_on_valid_parameters" do
	end

	test "update_failure_on_invalid_parameters" do
	end
end
