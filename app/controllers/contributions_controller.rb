require 'amazon/fps/multi_token_request'
require 'amazon/fps/pay_request'

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
		@contribution.payment_key = 'temp' #Needs to past initial validation
		if(user_signed_in?)
			@contribution.user_id = current_user.id
		end

		if @contribution.valid?
			#Worth considering alternatives if the performance on this is bad
			#E.g. memcached, writing to the DB and marking record incomplete
			session[:contribution] = @contribution
			request = Amazon::FPS::MultiTokenRequest.new(save_contribution_url, @project.payment_account_id, @contribution.amount, @project.name)
		
			redirect_to request.url()
		else
			render :action => :new
		end
	end

	#Return URL from payment gateway
	def save
		if !session[:contribution].nil? and !params[:tokenID].nil?
			@contribution = session[:contribution]
			session[:contribution] = nil
			@contribution.payment_key = params[:tokenID]
			if @contribution.save and @contribution.payment_key != 'temp'
				flash[:alert] = "Contribution entered successfully. Thanks for your support!"
				redirect_to root_path
			else
				flash[:alert] = "An error occurred with your contribution. Please try again."
				redirect_to root_path
			end
		end
	end

	# This should likely not be externally accessible 
	def executePayment
		@contribution = Contribution.find_by_id(params[:id])

    request = Amazon::FPS::PayRequest.new(@contribution.payment_key, @contribution.project.payment_account_id, @contribution.amount)
		
    response =  request.send()
		puts 'execute payment response', response

		logger.info response
		result = response['PayResponse']['PayResult']
		transaction_id = result['TransactionId']
	  transaction_status = result['TransactionStatus']

    if transaction_status == "Success"
			@contribution.complete = true
			@contribution.save
		end
	end

protected
	def validate_project
		if !@project.isValid?
			flash[:alert] = "The project you are trying to contribute to is inactive"
			redirect_to root_path	
		end
	end
end
