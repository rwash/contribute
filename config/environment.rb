# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Contribute::Application.initialize!

Date::DATE_FORMATS[:default] = "%m/%d/%Y"

THREAD_DEPTH = 16

# if you want to add a new state be sure to add it to the end of the array. Also add it as a valid state in the project model valid_state method
PROJ_STATES = ['unconfirmed', 'inactive', 'active', 'nonfunded', 'funded', 'canceled']

YT_DEV_KEY = 'AI39si5wMYM5Q5hivTEsSGrkm6vWRMyE-oOhwgE4QNss55LmgvvugH4vDOd9REkSBXDJL3vUE5WzXyXcll0gcCW3sFbdpqmxYA'
YT_USERNAME = 'Jake.Wesorick@gmail.com'
YT_PASSWORD = 'Crazy4DoctorWhoMan'