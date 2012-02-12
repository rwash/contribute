class RegistrationsController < Devise::RegistrationsController
	protected
		def after_update_path_for(resource)
			puts "THIS HAPPENED"
			user_path(resource)
		end
end
