require 'logger'

logger = Logger.new('log/cron_log.log')

namespace :contribute do
	# This task is scheduled to run and processes all projects that have an end date of yesterday
	task :completed_projects => :environment do
		logger.info "#{Date.today}: Starting completed_projects"

		projects_to_process = Project.where("end_date = :yesterday AND active = 1", { :yesterday => Date.yesterday })
		logger.info "Found #{projects_to_process.size} projects to process"

		process_projects(projects_to_process, logger)

		logger.info "#{Date.today}: All projects have been processed\n"
	end

	# This task is run when needed and processes all projects with an end date of yesterday or before
	task :all_completed_projects => :environment do
		logger.info "#{Date.today}: Starting all_completed_projects"

		all_projects_to_process = Project.where("end_date <= :yesterday AND active = 1", { :yesterday => Date.yesterday })
		logger.info "Found #{all_projects_to_process.size} projects to process"

		process_projects(all_projects_to_process, logger)

		logger.info "#{Date.today}: All projects have been processed\n"
	end

	def process_projects(projects, logger)
		projects.each do |project|
			if (project.contributions_total < project.funding_goal)
				logger.info "Project with id #{project.id} was not funded"
				EmailManager.project_not_funded_to_owner(project).deliver

				project.contributions.each do |contribution|
					logger.info "Contribution with id #{contribution.id} is being cancelled"
					EmailManager.project_not_funded_to_contributor(contribution).deliver
					contribution.cancel		
				end
			else
				logger.info "Project with id #{project.id} was funded"
				EmailManager.project_funded_to_owner(project).deliver

				project.contributions.each do |contribution|
					logger.info "Contribution with id #{contribution.id} is being executed"
					contribution.execute_payment		
					EmailManager.project_funded_to_contributor(contribution).deliver
				end
			end
		
			project.active = 0
			project.save(:validate => false)
		end
	end
end

