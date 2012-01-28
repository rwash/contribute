class ProjectsController < InheritedResources::Base
	actions :all, :except => [ :destroy ]

	def show
		begin
			show!
		rescue ActiveRecord::RecordNotFound
			redirect_to projects_url, notice: 'Invalid Project'
		end
	end

	def edit
		begin
			edit!
		rescue ActiveRecord::RecordNotFound
			redirect_to projects_url, notice: 'Invalid Project'
		end
	end
end
