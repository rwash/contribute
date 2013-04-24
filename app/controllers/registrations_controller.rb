class RegistrationsController < Devise::RegistrationsController
  def show
    @user = User.find(params[:id])
  end

  protected
  def after_update_path_for(resource)
    user_path(resource)
  end

  # Check out devise's source in lib/devise/controllers/helpers.rb
  # Look at after_sign_in_path_for
  def after_sign_up_path_for(resource)
    stored_location_for(resource) || edit_user_registration_path
  end
end
