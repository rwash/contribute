class EmailManager < ActionMailer::Base
  default :from => Rails.application.config.from_address

	@@admin_address = Rails.application.config.admin_address

	def add_project(project)
		@project = project
		@user = @project.user

		mail(:to => @user.email, :subject => "#{@project.name} has been created")
	end

	def contribute_to_project(contribution)
		@contribution = contribution
		@project = @contribution.project
		@user = @contribution.user

		mail(:to => @user.email, :subject => "Your contribution to #{@project.name}")
	end

	def edit_contribution(old_contribution, new_contribution)
		@old_contribution = old_contribution
		@new_contribution = new_contribution
		@project = @old_contribution.project
		@user = @old_contribution.user

		mail(:to => @user.email, :subject => "Your edited contribution to #{@project.name}")
	end

	def failed_cancellations(contributions_waiting_cancellation)
		@contributions = contributions_waiting_cancellation

		mail(:to => @@admin_address, :subject => "Contributions waiting for cancellation for more than 3 days")
	end

	def project_funded_to_owner(project)
		@project = project
		@user = @project.user
	
		mail(:to => @user.email, :subject => "Your project #{@project.name} was successfully funded!")
	end

	def project_not_funded_to_owner(project)
		@project = project
		@user = @project.user

		mail(:to => @user.email, :subject => "Your project #{@project.name} was did not reach its funding goal")
	end

	def project_funded_to_contributor(contribution)
		@contribution = contribution
		@project = @contribution.project
		@user = @contribution.user

		mail(:to => @user.email, :subject => "Project #{@project.name} was successfully funded!")
	end

	def project_not_funded_to_contributor(contribution)
		@contribution = contribution
		@project = @contribution.project
		@user = @contribution.user

		mail(:to => @user.email, :subject => "Project #{@project.name} was did not reach its funding goal")
	end
end
