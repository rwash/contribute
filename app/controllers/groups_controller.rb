class GroupsController < InheritedResources::Base
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
	
	def submit
		@group = Group.find(params[:id])
		@projects = %w[Jake Is Cool]
	end
	
	def approval
		@group = Group.find(params[:id])
		@project = Project.find(params[:project_id])
		#@group.projects << @project
		
		Approval.create(:group_id => @group.id, :project_id => @project.id)
		
		redirect_to @group
	end
	
	def admin
		@group = Group.find(params[:id])
	end
end