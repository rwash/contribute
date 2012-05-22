Contribute::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  #config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  #config.action_mailer.raise_delivery_errors = false

	# Tell Devise where to link back to in its confirmation e-mail
	config.action_mailer.default_url_options = { :host => 'orithena.cas.msu.edu' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

	#Amazon Payments Configuration
	config.amazon_cbui_endpoint = "https://authorize.payments-sandbox.amazon.com/cobranded-ui/actions/start"
	config.amazon_fps_endpoint = "https://fps.sandbox.amazonaws.com/"

#	These will be the real values when the account gets approved
	config.aws_access_key = "AKIAIVLAEPTVD6GUEKKQ"
	config.aws_secret_key = "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"

	#Email Configuration
	config.from_address = "Contribute <gethelp@contribute.cas.msu.edu>"
	config.admin_address = "devenv@bitlab.cas.msu.edu"
	
	#Useing Email on localhost
	# used with mailcatcher 'gem install mailcatcher', then just run by typing 'mailcatcher'
	config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {:address => "localhost", :port => 1025}
  
  COMMENTS_DEPTH = 3

end
