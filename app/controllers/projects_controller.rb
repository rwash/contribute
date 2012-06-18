require 'amazon/fps/recipient_request'
require 'amazon/fps/amazon_logger'
require 'amazon/fps/amazon_validator'

class ProjectsController < InheritedResources::Base
	actions :all, :except => [ :create, :edit, :update, :destroy ]

	before_filter :authenticate_user!, :only => [ :new, :create, :edit, :update, :destroy, :save]
	#This allows us to use project names instead of ids for the routes
	before_filter :set_current_project_by_name, :only => [ :show, :edit, :update, :destroy ]
	#This is authorization through CanCan. The before_filter handles load_resource
	authorize_resource


	def index
		@projects = Project.where(:state => PROJ_STATES[2]).order("end_date ASC").page(params[:page]).per(2)
		#@projects = Project.limit(9).where("active = 1 and confirmed = 1").order("end_date ASC")
		#@projects1 = @projects.slice(0..2) || []
		#@projects2 = @projects.slice(3..5) || []
		#@projects3 = @projects.slice(6..8) || []
		index!
	end

	def create
		@project = Project.new(params[:project])
		@project.user_id = current_user.id
		@project.payment_account_id = Project::UNDEFINED_PAYMENT_ACCOUNT_ID #To pass validation at valid?
		@project.state = PROJ_STATES[0] #unconfirmed
	
		if @project.valid?
			@project.save
			session[:project_id] = @project.id

			request = Amazon::FPS::RecipientRequest.new(save_project_url)
			return redirect_to request.url
		else
			render :action => :new
		end
	end
	
	def update
		@project = Project.where(:name => params[:id].gsub(/-/, ' ')).first 
		if params[:activate] == 'true'
			@project.state = PROJ_STATES[2] #active
			@project.save!
			flash[:notice] = "Successfully activated project." 
    elsif @project.update_attributes(params[:project])
      flash[:notice] = "Successfully updated project."
    end
    
    if @project.unconfirmed?
    	session[:project_id] = @project.id
			request = Amazon::FPS::RecipientRequest.new(save_project_url)
			return redirect_to request.url
    else 
    	respond_with(@project)
    end
	end

	def save
		Amazon::FPS::AmazonLogger::log_recipient_token_response(params)

		if !Amazon::FPS::AmazonValidator::valid_recipient_response?(save_project_url, session, params)
			flash[:alert] = "An error occurred with your project. Please try again."
			return redirect_to root_path
		end

		@project = Project.find_by_id(session[:project_id])
		@project.state = PROJ_STATES[1] #inactive
		@project.payment_account_id = params[:tokenID]

		session[:project_id] = nil

		if !@project.save 
			flash[:alert] = "An error occurred with your project. Please try again."	
			return redirect_to root_path
		else
			#TODO: This is inconsistent. All the other project and contribution e-mails go through the 
			# model. Might be worth doing that for this too.
			successful_save

			flash[:alert] = "Project saved successfully. Here's to getting funded!"
			return redirect_to current_user
		end
	end

	def destroy
		@project = Project.where(:name => params[:id].gsub(/-/, ' ')).first
		
		if @project.state == PROJ_STATES[0] || @project.state == PROJ_STATES[1]
			if !@project.destroy
				flash[:alert] = "Project could not be deleted. Please try again."
				return redirect_to @project
			else 
				flash[:alert] = "Project successfully deleted. Sorry to see you go!"
				return redirect_to root_path
			end
		elsif @project.state == PROJ_STATES[2]
			#project will not be deleted but will be CANCELED and only visible to user
			@project.state = PROJ_STATES[5] #canceled
			@project.save!
			flash[:alert] = "Project successfully canceled. Project is now only visible to you."
		else
			flash[:alert] = "You can not cancel or delete this project."
		end
		return redirect_to root_path
	end
	
  def show
    @project = Project.where(:name => params[:id].gsub(/-/, ' ')).first
    @video = Video.find(@project.video_id) if !@project.video_id.nil?
    
    @rootComments = @project.root_comments
    @comment = Comment.new(params[:comment])
    @comment.commentable_id = @project.id
    @comment_depth = 0
    
    @update = Update.new(params[:update])
    @updates = Update.where(:project_id => @project.id)
  end
  
  def edit
  	@project = Project.where(:name => params[:id].gsub(/-/, ' ')).first
  end
  
  def upload
  	@project = Project.where(:name => params[:id].gsub(/-/, ' ')).first
  	
  	if !@project.video_id.nil?
  		@old_vid = Video.find(@project.video_id)
  		Video.delete_video(@old_vid)
  	end
  	
  	@video = Video.create(:title => @project.name, :description => @project.short_description)
  	@project.video_id = @video.id
  	@project.save!
  	
    if @video
      @upload_info = Video.token_form(@video.title, @video.description, save_video_new_video_url(:video_id => @video.id))
    end
  end

protected	
	def successful_save
		EmailManager.add_project(@project).deliver
	end
end
