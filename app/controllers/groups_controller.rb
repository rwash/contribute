class GroupsController < InheritedResources::Base
	load_and_authorize_resource
	before_filter :authenticate_user!, :only => [ :new, :create, :edit, :update, :destroy, :save]
	
	def index
		@groups = Group.all
		
		@user_groups = []
		for project in current_user.projects
			for group in project.groups
				@user_groups << group
			end
		end
		@user_groups.uniq!
		
		@admin_groups = current_user.owned_groups
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
	end
	
	def submit_add
		@group = Group.find(params[:id])
		@project = Project.find(params[:project_id])
		
		if @project.cancelled?
			flash[:error] = "You cannot add a canceld project to a group."
		elsif @group.projects.include?(@project)
			flash[:error] = "Your project is already in this group."
		elsif @group.open?
			@group.projects << @project
			
			@pi = Item.create(:itemable_id => @project.id, :itemable_type => @project.class.name, :list_id => @group.lists.first.id)
			
			@video = Video.find_by_id(@project.video_id)
			@project.update_project_video unless @video.nil?
			
    	flash[:notice] = "Your project has been added to the group."
		elsif !Approval.where(:group_id => @group.id, :project_id => @project.id, :approved => nil).first.nil?
			flash[:error] = "You have already submitted a request. Please wait for the group owner to decide."
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
		@items = @group.lists.first.items
	end
	
	def remove_project
		@group = Group.find(params[:id])
		@project = Project.find_by_name(params[:project_id].gsub(/-/, ' '))
		@group.projects.delete(@project)
		@project.update_project_video unless @project.video_id.nil?
		
		redirect_to :back
	end
end