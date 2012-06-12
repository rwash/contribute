# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Contribute::Application.initialize!

Date::DATE_FORMATS[:default] = "%m/%d/%Y"

THREAD_DEPTH = 16

# if you want to add a new state be sure to add it to the end of the array. Also add it as a valid state in the project model valid_state method
PROJ_STATES = ['unconfirmed', 'inactive', 'active', 'nonfunded', 'funded', 'canceled']
