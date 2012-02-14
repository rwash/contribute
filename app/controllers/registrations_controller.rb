class RegistrationsController < Devise::RegistrationsController
	def show
		@user = User.find_by_id(params[:id])
	end

	protected
		def after_update_path_for(resource)
			user_path(resource)
		end
end
