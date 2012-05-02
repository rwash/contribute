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

	def contribution_cancelled(contribution)
		@contribution = contribution
		@project = @contribution.project
		@user = @contribution.user

		mail(:to => @user.email, :subject => "Your contribution to #{@project.name} was successfully cancelled")
	end

	def contribution_successful(contribution)
		@contribution = contribution
		@project = @contribution.project
		@user = @contribution.user

		mail(:to => @user.email, :subject => "Your contribution to #{@project.name} was successfully completed")
	end

	def failed_retries(contributions_still_failing)
		@contributions = contributions_still_failing

		mail(:to => @@admin_address, :subject => "#{Date.today}: Contributions failed more than 3 times")
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

		mail(:to => @user.email, :subject => "The project #{@project.name} was successfully funded!")
	end

	def project_not_funded_to_contributor(contribution)
		@contribution = contribution
		@project = @contribution.project
		@user = @contribution.user

		mail(:to => @user.email, :subject => "The project #{@project.name} was did not reach its funding goal")
	end

	def project_deleted_to_owner(project)
		@project = project
		@user = @project.user

		mail(:to => @user.email, :subject => "Your project #{@project.name} was successfully deleted")
	end

	def project_deleted_to_contributor(contribution)
		@contribution = contribution
		@project = @contribution.project
		@user = @contribution.user

		mail(:to => @user.email, :subject => "The project #{@project.name} has been deleted")
	end

	def unretriable_cancel_to_admin(error, contribution)
		@contribution = contribution
		@error = error

		mail(:to => @@admin_address, :subject => "Contribution id: #{@contribution.id} has failed cancellation")
	end

	def unretriable_payment_to_user(error, contribution)
		@contribution = contribution
		@project = @contribution.project
		@user = @contribution.user
		@error = error

		mail(:to => @user.email, :subject => "Attention! We need your help to fix your contribution to #{@project.name}!") 
	end

	def unretriable_payment_to_admin(error, contribution)
		@contribution = contribution
		@project = @contribution.project
		@error = error

		mail(:to => @@admin_address, :subject => "Contribution id: #{@contribution.id} has failed executing payment")
	end

	def cancelled_payment_to_admin(contribution)
		@contribution = contribution
		@project = @contribution.project

		mail(:to => @@admin_address, :subject => "Contribution id: #{@contribution.id} was cancelled before payment could complete successfully")
	end

	def failed_payment_to_user(contribution)
		@contribution = contribution
		@project = @contribution.project
		@user = @contribution.user

		mail(:to => @user.email, :subject => "Attention! We need your help to fix your contribution to #{@project.name}!") 
	end

	def failed_status_to_admin(error, contribution)
		@contribution = contribution
		@project = @contribution.project
		@error = error

		mail(:to => @@admin_address, :subject => "Contribution id: #{@contribution.id} has failed checking its transaction status")
	end
end
