require 'amazon/fps/multi_token_request'
require 'amazon/fps/pay_request'
require 'amazon/fps/cancel_token_request'

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
		@contribution.payment_key = Contribution::UNDEFINED_PAYMENT_KEY #To pass validation at valid?
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
			#Verify response status
			#Verify signature received
			@contribution = session[:contribution]
			session[:contribution] = nil
			@contribution.payment_key = params[:tokenID]
			if @contribution.save
				flash[:alert] = "Contribution entered successfully. Thanks for your support!"
				redirect_to root_path
			else
				flash[:alert] = "An error occurred with your contribution. Please try again."
				redirect_to root_path
			end
		else
			flash[:alert] = "An error occurred with your contribution. Please try again."
			redirect_to root_path
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

	def edit
		initialize_editing_contribution()
		
		#else, create a new contribution
		@contribution = Contribution.new
	end

	def show
		raise ActionController::RoutingError.new('Not Found')
	end

	def update
		initialize_editing_contribution()
		@contribution = Contribution.new params[:contribution]

		#Setup contribution parameters that aren't specified by user...
		@contribution.project_id = @project.id
		@contribution.payment_key = Contribution::UNDEFINED_PAYMENT_KEY #To pass validation at valid?
		if(user_signed_in?)
			@contribution.user_id = current_user.id
		end

		if @contribution.valid?
			#Put the logic of cancelling payments here
			#First, send the new contribution
			session[:contribution] = @contribution
			session[:editing_contribution_id] = @editing_contribution.id
			request = Amazon::FPS::MultiTokenRequest.new(after_update_contribution_url, @project.payment_account_id, @contribution.amount, @project.name)
		
			redirect_to request.url()
		else
			render :action => :edit	
		end
	end

	def after_update
		if !session[:contribution].nil? and !params[:tokenID].nil? and !session[:editing_contribution_id].nil?
			#Verify response status
			#Verify signature received
			@contribution = session[:contribution]
			@editing_contribution = Contribution.find_by_id(session[:editing_contribution_id])

			session[:contribution] = nil
			session[:editing_contribution_id] = nil

			@contribution.payment_key = params[:tokenID]
			if @contribution.valid?
				#Cancel previous token
				request = Amazon::FPS::CancelTokenRequest.new(@editing_contribution.payment_key)
				response = request.send()

				#If it was successful, we'll mark the record as cancelled
				if response["Errors"].nil?
					@editing_contribution.cancelled = 1
				#otherwise we'll mark it as pending and try again later
				else
					@editing_contribution.waiting_cancellation = 1
				end

				if !@editing_contribution.save
					flash[:alert] = "An error occured trying to cancel your previous contribution. Please try again."
					redirect_to root_path
				end

				@contribution.save
				flash[:alert] = "Contribution successfully updated. Thanks for your support!"
				redirect_to root_path
			else
				flash[:alert] = "An error trying to update your contribution. Please try again."
				redirect_to root_path
			end
		else
			flash[:alert] = "An error occurred trying to update contribution. Please try again."
			redirect_to root_path
		end

	end

protected
	def validate_project
		if !@project.isValid?
			flash[:alert] = "The project you are trying to contribute to is inactive"
			redirect_to root_path	
		end
	end

	def initialize_editing_contribution
		#store editing contribution for return from amazon
		@editing_contribution = Contribution.find_by_id(params[:id])

		#if it's not there, get out
		if @editing_contribution.nil?
			flash[:notice] = "Could not find the contribution your were trying to edit"
			redirect_to root_url
		end

		@project = @editing_contribution.project
		validate_project
	end
end
