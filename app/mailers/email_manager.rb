class EmailManager < ActionMailer::Base
  default from: "no-reply@contribute.cas.msu.edu"

	def add_project(user, project)
		@user = user
		@project = project

		mail(:to => @user.email, :subject => "Contribute: #{@project.name} has been created")
	end
end
