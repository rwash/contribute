source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# RSpec is our testing framework, at the heart of our tests
gem 'rspec-rails', :group => [:test, :development]
group :test do
  # Pretty printed test output
  gem 'turn', '~> 0.8.3', :require => false
	# Factory Girl is used in place of fixtures
	# to make test objects for our tests to use
	gem 'factory_girl_rails', '~> 1.2'
	gem 'shoulda-matchers'
	# Guard automatically runs tests when you save a file
	# Run it by doing "bundle exec guard"
	gem 'guard-rspec'
	# Capybara is used for integration testing, the stuff you
	# find in the spec/requests folder
	gem 'capybara'
	# Driver for Capybara
	gem 'selenium-webdriver', '>= 2.5.0'
	# Allows integration tests to be run on machiness
	# without a monitor
	gem 'headless'
	# Code coverage!
	gem 'simplecov', :require => false
end

# Deploy with Capistrano
gem 'capistrano'

# To use debugger (which I never got to work)
#gem 'ruby-debug19', :require => 'ruby-debug'
#gem 'linecache19'
#gem 'ruby-debug-base19x', '~> 0.11.30.pre4'

gem 'mysql2'
gem 'json'

# Used in ProjectsController to create default CRUD methods
gem 'inherited_resources'

# User account management/authentication
gem 'devise'
# Needed to run devise:views at the least
gem 'therubyracer'

# DateTime parser
# Used to be able to process dates that are in a MM/DD/YY format for
# project end date
gem 'timeliness'

# Authorization
# The configuration file is found in app/models/ability.rb. It describes
# what permissions are allowed to certain types of users. It's enforced
# in controllers by authorize_resource call
gem 'cancan'

# Pictures
# Projects and Users both have pictures, which are managed by this
# Gem. We moved from PaperClip to this since PaperClip wouldn't let
# us cache the pictures when validation failed
gem 'carrierwave'
# Resizing in Carrierwave
# Dependency Carrierwave has to be able to resize pictures to more
# useful sizes
gem 'rmagick'

# REST interaction
# Some Amazon interaction is the user through a browser, the rest
# is us talking directly to their API, we use HTTPParty for that.
gem 'httparty'

# GUID generation
# Our Amazon requests need a unique identifier which they refer
# to as a CallerReference. What better unique id than a GUID?
gem "uuidtools", "~> 2.1.2"

# Caching gem
# Dalli is a Rails Memcached gem. We use caching for values around
# the site and on some fragments of pages.
# Memcache is a separate program from this gem that can be run by
# doing "memcached" but should already be running as a daemon.
gem "dalli"

# Web server for testing
gem "mongrel"

# Task scheduler 
# Configuration found at config/schedule.rb
# Used to run our custom rake tasks when needed
gem 'whenever'

# Bootstrap
# CSS framework used to make the site all nice and purty
gem "twitter-bootstrap-rails"

#Documentation generation
gem 'rdoc'
