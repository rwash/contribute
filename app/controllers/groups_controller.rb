class GroupsController < InheritedResources::Base
	load_and_authorize_resource
	before_filter :authenticate_user!, :only => [ :new, :create, :edit, :update, :destroy, :save, :new_add]
	
	def index
		@groups = Group.all
		
		unless current_user.nil?
			@user_groups = []
			for project in current_user.projects
				for group in project.groups
					@user_groups << group
				end
			end
			@user_groups.uniq!
			@admin_groups = current_user.owned_groups
		end
	end
	
	def create
		@group = Group.new(params[:group])
		@group.admin_user_id = current_user.id
		
		if @group.save!
			flash[:notice] = "Successfully created group."
			redirect_to @group
		else
			flash[:error] = "Failed to save group."
			redirect_to new_group_path
		end
	end
	
	def new_add
		@group = Group.find(params[:id])
		@projects = []
		for proj in current_user.projects
			@projects << proj if !@group.projects.include?(proj) && proj.state != 'canceled'
		end
	end
	
	def submit_add
		@group = Group.find(params[:id])
		@project = Project.find_by_id(params[:project_id])
		
		if @project.nil?
			#Do Nothing
		elsif @project.cancelled?
			flash[:error] = "You cannot add a canceld project to a group."
		elsif @group.projects.include?(@project)
			flash[:error] = "Your project is already in this group."
		elsif @group.open?
			@group.projects << @project			
			@video = Video.find_by_id(@project.video_id)
			@project.update_project_video unless @video.nil?
			
    	flash[:notice] = "Your project has been added to the group."
		elsif !Approval.where(:group_id => @group.id, :project_id => @project.id, :approved => nil).first.nil?
			flash[:error] = "You have already submitted a request. Please wait for the group owner to decide."
		elsif @group.admin_user_id == current_user.id
			@group.projects << @project
			flash[:notice] = "Your project has been added and automagically approved because you are the group admin."
		else
			@approval = Approval.create(:group_id => @group.id, :project_id => @project.id)
			flash[:notice] = "Your project has been submitted to the group owner for approval."
			if @project.active? || @project.funded? || @project.nonfunded?
				EmailManager.project_to_group_approval(@approval, @project, @group).deliver
			end
		end

		redirect_to @group
	end
	
	def admin
		@group = Group.find(params[:id])
		@approval = Approval.find_by_id(params[:approval_id])
		#@items = @group.lists.first.items
	end
	
	def remove_project
		@group = Group.find(params[:id])
		@project = Project.find_by_name(params[:project_id].gsub(/-/, ' '))
		if @group.admin_user_id == current_user.id or @project.user_id == current_user.id
			@group.projects.delete(@project)
			@project.update_project_video unless @project.video_id.nil?
			flash[:notice] = "#{@project.name} removed from group #{@group.name}."
		else
			flash[:error] = "You must be the admin of the group or the projects owner to remove it from a project."
		end
		
		redirect_to :back
	end
	
	def add_list
		@group = Group.find(params[:id])
		@group.lists << List.create(:listable_id => @group.id, :listable_type => @group.class.name)
		
		redirect_to :back
	end
	
	def destroy
		@group = Group.find(params[:id])
		if !@group.destroy
			flash[:error] = "Failed to delete Group"
		end
		redirect_to groups_path
	end
end