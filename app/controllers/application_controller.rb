class ApplicationController < ActionController::Base
 protect_from_forgery

  helper_method :logged_in?, :comment_owner

	rescue_from CanCan::AccessDenied do |exception|
		if exception.action == :contribute
			redirect_to exception.subject, :alert => exception.message
		elsif exception.action == :edit_contribution
			redirect_to exception.subject, :alert => exception.message
		else
			redirect_to root_url, :alert => exception.message
		end
	end

 	def set_current_project_by_name
		@project = Project.find_by_name(params[:id])
	end
	
	 def logged_in?
    !current_user.nil?
  end
  
  def comment_owner(comment)
   logged_in? && current_user.id == comment.user_id
  end
end
