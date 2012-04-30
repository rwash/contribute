def assert_contribution_failure(path)
	response.should redirect_to(path)
	assert flash[:alert].include?("error"), flash[:alert]
end

