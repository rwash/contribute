# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Contribute::Application.initialize!

Date::DATE_FORMATS[:default] = "%m/%d/%Y"

THREAD_DEPTH = 16
PROJ_STATES = ['unconfirmed', 'inactive', 'active', 'nonfunded', 'funded', 'canceled']
