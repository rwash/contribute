require 'amazon/fps/recipient_request'
require 'amazon/fps/amazon_logger'
require 'amazon/fps/amazon_validator'

class ProjectsController < InheritedResources::Base
	actions :all, :except => [ :create, :edit, :update, :destroy ]

	before_filter :authenticate_user!, :only => [ :new, :create, :edit, :update, :destroy, :save ]
	#This allows us to use project names instead of ids for the routes
	before_filter :set_current_project_by_name, :only => [ :show, :edit, :update, :destroy ]
	#This is authorization through CanCan. The before_filter handles load_resource
	authorize_resource

	def index
		@projects = Project.limit(9).where("active = 1").order("end_date ASC")
		@projects1 = @projects.slice(0..2) || []
		@projects2 = @projects.slice(3..5) || []
		@projects3 = @projects.slice(6..8) || []
		index!
	end

	def create
		@project = Project.new(params[:project])
		@project.user_id = current_user.id
		@project.payment_account_id = Project::UNDEFINED_PAYMENT_ACCOUNT_ID #To pass validation at valid?
	
		if @project.valid?
			@project.save
			session[:project_id] = @project.id

			request = Amazon::FPS::RecipientRequest.new(save_project_url)
			return redirect_to request.url
		else
			render :action => :new
		end
	end

	def save
		Amazon::FPS::AmazonLogger::log_recipient_token_response(params)

		if !Amazon::FPS::AmazonValidator::valid_recipient_response?(save_project_url, session, params)
			flash[:alert] = "An error occurred with your project. Please try again."	
			return redirect_to root_path
		end

		@project = Project.find_by_id(session[:project_id])
		@project.confirmed = true
		@project.payment_account_id = params[:tokenID]

		session[:project_id] = nil

		if !@project.save 
			flash[:alert] = "An error occurred with your project. Please try again."	
			return redirect_to root_path
		else
			successful_save

			flash[:alert] = "Project saved successfully. Here's to getting funded!"
			return redirect_to @project
		end
	end

	def destroy
		if !@project.destroy
			flash[:alert] = "Project could not be deleted. Please try again."
			return redirect_to @project
		else 
			#TODO: This is inconsistent. Contribution sends the e-mail in the model. Project should too
			# provided that we can assume save is successful always
			successful_destroy

			flash[:alert] = "Project successfully deleted. Sorry to see you go!"
			return redirect_to root_path
		end
	end

protected	
	def successful_save
		EmailManager.add_project(@project).deliver
	end

	def successful_destroy
		EmailManager.project_deleted_to_owner(@project).deliver	
	end
end
