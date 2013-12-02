# Load the rails application
require File.expand_path('../application', __FILE__)
require_relative 'secrets'

# Initialize the rails application
Contribute::Application.initialize!

Date::DATE_FORMATS[:default] = "%m/%d/%Y"

THREAD_DEPTH = 16

#you-tube
YT_DEV_KEY = 'AI39si66_SkYIHlMQg0fKZ3yAz64tPDEAbzNm1af9FqmXeMgH5tHFPtGgSsVcUMzpKCOhKliREq0l467cgS-WIgrgxPzlQlerw'
YT_USERNAME = 'contributeMSU'
YT_PASSWORD = 'somthingcool'
YT_TAGS = %w[Contribute crowdfunding MSU] << "Michigan State University" # these tags will be added to all videos uploaded to youtube

# Braintree payment processing
Braintree::Configuration.environment = :sandbox
