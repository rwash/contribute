class GroupsController < InheritedResources::Base
	load_and_authorize_resource
	
	def index
		@groups = Group.all
	end
	
	def create
		@group = Group.new(params[:group])
		@group.admin_user_id = current_user.id
		
		if @group.save!
			redirect_to @group
		else
			flash[:error] = "Failed to save group."
			redirect_to new_group_path
		end
	end
	
	def new_approval
		@group = Group.find(params[:id])
		if @group.open?
			@submit_path = 'open-add'
		else
			@submit_path = 'submit-approval'
		end
	end
	
	def open_add
		@group = Group.find(params[:id])
		@project = Project.find(params[:project_id])
		
		unless @group.projects.include?(@project)
			@group.projects << @project
			flash[:notice] = "Your project has been added to the group."
		else
			flash[:error] = "Your project is already in this group."
		end
		
		redirect_to @group
	end
	
	def admin
		@group = Group.find(params[:id])
		@approval = Approval.find_by_id(params[:approval_id])
	end
	
	def remove_project
		@group = Group.find(params[:id])
		@project= Project.find_by_name(params[:project_id])
		@group.projects.delete(@project)
		redirect_to :back
	end
end