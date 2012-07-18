class ApprovalsController < InheritedResources::Base
	def submit
		@group = Group.find(params[:id])
		@project = Project.find(params[:project_id])
		#@group.projects << @project
		
		if !Approval.where(:group_id => @group.id, :project_id => @project.id, :approved => nil).first.nil?
			flash[:error] = "You have already submitted a request. Please wait for the group owner to decide."
		elsif @group.projects.include?(@project)
			flash[:error] = "You project has already been approved and is in this group."
		elsif @project.cancelled?
			flash[:error] = "You cannot submit a canceled project to a group."
		else
			Approval.create(:group_id => @group.id, :project_id => @project.id)
			flash[:notice] = "Your project has been submitted to the group owner for approval."
		end
		
		redirect_to @group
	end
	
	def approve
		@approval = Approval.find(params[:id])
		@group = Group.find(params[:group_id])
		
		@approval.approved = true
		@approval.save!
		@group.projects << Project.find(@approval.project_id)
		
		redirect_to :back
	end
	
	def reject
		@approval = Approval.find(params[:id])
		
		@approval.reason = params[:reason]
		@approval.approved = false
		@approval.save!
		
		redirect_to :back
	end
end