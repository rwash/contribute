class ApplicationController < ActionController::Base
 protect_from_forgery

 	def set_current_project_by_name
		@project = Project.find_by_name(params[:id])
	end
end
