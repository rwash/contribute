class EmailManager < ActionMailer::Base
  default :from => Rails.application.config.from_address

	@@admin_address = Rails.application.config.admin_address

	def add_project(user, project)
		@user = user
		@project = project

		mail(:to => @user.email, :subject => "#{@project.name} has been created")
	end

	def contribute_to_project(user, contribution)
		@user = user
		@contribution = contribution
		@project = @contribution.project

		mail(:to => @user.email, :subject => "Your contribution to #{@project.name}")
	end

	def edit_contribution(user, old_contribution, new_contribution)
		@user = user
		@old_contribution = old_contribution
		@new_contribution = new_contribution
		@project = @old_contribution.project

		mail(:to => @user.email, :subject => "Your edited contribution to #{@project.name}")
	end

	def failed_cancellations(contributions_waiting_cancellation)
		@contributions = contributions_waiting_cancellation

		mail(:to => @@admin_address, :subject => "Contributions waiting for cancellation for more than 3 days")
	end
end
