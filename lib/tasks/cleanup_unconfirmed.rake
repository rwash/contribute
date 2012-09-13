require 'logger'

logger = Logger.new('log/cron_log.log')

namespace :contribute do
	task :cleanup_unconfirmed => :environment do
		logger.info "#{Date.today}: Starting cleanup_unconfirmed"

		unconfirmed_projects(logger)
		unconfirmed_contributions(logger)
	
		logger.info "#{Date.today}: All unconfirmed resources have been processed\n"
	end

	def unconfirmed_projects(logger)
		# Select projects that are unconfirmed and were created 6 hours ago or more
		to_delete_projects = Project.where("confirmed = :confirmed and created_at <= :time", { :confirmed => false, :time => (DateTime.now - 6.hours) })
		logger.info "Found #{to_delete_projects.size} unconfirmed projects to delete"
	
		to_delete_projects.each do |project|
			logger.info "Project with id #{project.id} will be deleted"
			project.delete
		end
		
	end
	
	def unconfirmed_contributions(logger)
		to_delete_contributions = Contribution.where("confirmed = :confirmed and created_at <= :time", { :confirmed => false, :time => (DateTime.now - 6.hours) })
		logger.info "Found #{to_delete_contributions.size} unconfirmed projects to delete"
		
		to_delete_contributions.each do |contribution|
			logger.info "Contribution with id #{contribution.id} will be deleted"
			contribution.delete
		end
	end
end
