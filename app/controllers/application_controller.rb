class ApplicationController < ActionController::Base
 protect_from_forgery

	rescue_from CanCan::AccessDenied do |exception|
		redirect_to root_url, :alert => 'You must be signed in to perform this action'
	end

 	def set_current_project_by_name
		@project = Project.find_by_name(params[:id])
	end
end
