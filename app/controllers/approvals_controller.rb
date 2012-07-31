class ApprovalsController < InheritedResources::Base	
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