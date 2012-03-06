class ContributionsController < ApplicationController

	def new
 		@project = Project.find_by_name params[:project]
		validate_project

		@contribution = Contribution.new
	end

	def create
 		@project = Project.find_by_id params[:contribution][:project_id]
		validate_project

		@contribution = Contribution.new params[:contribution]
		if(user_signed_in?)
			@contribution.user_id = current_user.id
		end

		#Worth considering alternatives if the performance on this is bad
		#E.g. memcached, writing to the DB and marking record incomplete
		session[:contribution] = @contribution

		#Make API call
		#Get preapproval key, store in session
		#Redirect to payment gateway approval
	end

	#Return URL from payment gateway
	def save
		unless session[:contribution].nil? or session[:payment_key].nil?
			@contribution = session[:contribution]
			@contribution.payment_key = session[:payment_key]
			if @contribution.save
				flash[:alert] = "Contribution entered successfully. Thanks for your support!"
				redirect_to root_path
			else
				flash[:alert] = "An error occurred with your contribution. Please try again."
				redirect_to root_path
			end
		end
	end

	#Cancel URL from payment gateway
	def cancel
		session[:contribution] = nil
		session[:payment_key] = nil
		
		flash[:alert] = "Contribution was cancelled"
		redirect_to root_path
	end

	def executePayment
		#Make API call
	end

protected
	def validate_project
		if !@project.isValid?
			flash[:alert] = "The project you are trying to contribute to is inactive"
			redirect_to root_path	
		end
	end
end
