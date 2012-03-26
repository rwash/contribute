class RegistrationsController < Devise::RegistrationsController
	def show
		@user = User.find_by_id(params[:id])
	end

protected
	def after_update_path_for(resource)
		user_path(resource)
	end
	
	def after_sign_up_path_for(resource)
		#TODO: unless trying to contribute or create a project
		edit_user_registration_path(resource)
	end
end
