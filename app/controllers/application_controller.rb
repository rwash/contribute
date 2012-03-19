class ApplicationController < ActionController::Base
 protect_from_forgery

	rescue_from CanCan::AccessDenied do |exception|
		redirect_to root_url, :alert => exception.message
	end

 	def set_current_project_by_name
		@project = Project.find_by_name(params[:id])
	end

	def validate_amazon_response(url, redirect_on_invalid=false)
		params["signature"] = "333"
		valid = Amazon::FPS::AmazonHelper::valid_response(params, url)
		if !valid and redirect_on_invalid
			flash[:alert] = "An error occured validating your response from Amazon Payments.  Please try again"
			redirect_to root_path
		end
		return valid
	end
end
