# This is the ruby that is behind the retry_contributions rake task
# Pulling it out makes it way easier to test
require 'logger'

class UpdateContributors
	@@logger = Logger.new('log/cron_log.log')

	def self.run
		@@logger.info "#{Date.today}: Starting update_contributeors"

		updates_to_process = Update.where(:email_sent => false)
		@@logger.info "Found #{updates_to_process.size} updates to process"

		process_updates(updates_to_process)

		@@logger.info "#{Date.today}: All updates have been processed\n\n"
	end

	def self.process_updates(updates)
		updates.each do |update|
			@project = Project.find(update.project_id)
			@project.contributions.each do |contribution|
				@@logger.info "User with contribution with id #{contribution.id} is being emailed with update"
				EmailManager.project_update_to_contributor(update, contribution).deliver
			end
		
			update.email_sent = true
			update.save!
		end
	end
end
