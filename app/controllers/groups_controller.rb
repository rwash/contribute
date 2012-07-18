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
	
	def new_approval
		@group = Group.find(params[:id])
	end
	
	def admin
		@group = Group.find(params[:id])
	end
end