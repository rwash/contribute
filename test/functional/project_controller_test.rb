require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

	setup do
		@project = get_valid_project(:goggles)
	end

	#SHOW TESTING
	test "show_on_valid_id" do
		get(:show, id: @project.id)
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
		assert_select "h2", {text: /(.*)error(.*)/}, "heading does not contain errors"
		
		#put project back in db
		@project.fundingGoal = 6
		@project.save!
	end

	test "update_success_on_valid_parameters" do
		put :update, id: @project.to_param, project: @project.attributes
		assert_redirected_to project_path(assigns(:project))
	end

	test "update_failure_on_invalid_parameters" do
		@project.fundingGoal = -1
		put :update, id: @project.to_param, project: @project.attributes
		assert_select "h2", {text: /(.*)error(.*)/}, "heading does not contain errors" 
	end
end
