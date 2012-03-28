#TODO: This needs to log somewehere

namespace :contribute do
	task :process_completed_projects => :environment do
		projects_to_process = Project.where("end_date = :today AND active = 1", { :today => Date.today})

		projects_to_process.each do |project|
			if(project.contributions_total < project.funding_goal)
				project.contributions.each do |contribution|
					contribution.cancel		
					#send e-mail
				end
			else
				project.contributions.each do |contribution|
					contribution.execute_payment		
					#send e-mail
				end
			end

			project.active = 0
			project.save(:validate => false)
		end
	end
end
