class ApplicationController < ActionController::Base
 protect_from_forgery

	rescue_from CanCan::AccessDenied do |exception|
		redirect_to root_url, :alert => exception.message
	end

 	def set_current_project_by_url_name
		@project = Project.find_by_url_name(params[:id])
	end
end
