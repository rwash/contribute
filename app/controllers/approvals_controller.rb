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
			@approval = Approval.create(:group_id => @group.id, :project_id => @project.id)
			flash[:notice] = "Your project has been submitted to the group owner for approval."
			if @project.active? || @project.funded? || @project.nonfunded?
				EmailManager.project_to_group_approval(@approval, @project, @group).deliver
			end
		end
		
		redirect_to @group
	end
	
	def approve
		@approval = Approval.find(params[:id])
		@group = Group.find(params[:group_id])
		
		if @approval.approved.nil?
			@approval.approved = true
			@approval.save!
			
			@project = Project.find(@approval.project_id)
			@group.projects << @project
			@project.update_project_video unless @project.video_id.nil?
			
		else
			flash[:error] = "This project has alreaad been #{(@approval.approved)? 'approved' : 'denied'}."
		end
		
		redirect_to group_admin_path(@group)
	end
	
	def reject
		@approval = Approval.find(params[:id])
		@group = Group.find(params[:group_id])
		@project = Project.find(@approval.project_id)
		if @approval.approved.nil?
			@approval.reason = params[:reason]
			@approval.approved = false
			@approval.save!
		
			EmailManager.group_reject_project(@approval, @project, @group).deliver
		else
			flash[:error] = "This project has alreaad been #{(@approval.approved)? 'approved' : 'denied'}."
		end
		
		redirect_to group_admin_path(@group)
	end
end