source 'http://rubygems.org'

gem 'rails', '~> 3.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '~> 1.3.0'
end

gem 'jquery-rails', '~> 2.2.1'

# RSpec is our testing framework, at the heart of our tests
gem 'rspec-rails', group: [:test, :mysql_test, :mysql_development, :development]

# Testing gems!
group :test, :mysql_test do
  # Factory Girl is used in place of fixtures
  # to make test objects for our tests to use
  gem 'factory_girl_rails', '~> 4.0'
  # One-line tests for models and controllers
  gem 'shoulda-matchers', '~> 1.4.2'
  # Capybara is used for integration testing, the stuff you
  # find in the spec/requests folder
  gem 'capybara', '~> 2.0.2'
  # Driver for testing Javascript with Capybara
  gem 'capybara-webkit', '~> 0.14.2'
  # Open page for examination during a test - used for debugging failing tests.
  gem 'launchy', '~> 2.2.0'
  # Code coverage!
  gem 'simplecov', '~> 0.7.1', require: false
  # Test time-sensitive behavior without having to wait days
  gem 'timecop', '~> 0.5.9.1'
  # Pretty formatting for rspec test runs
  gem 'fuubar', '~> 1.2.1'
  # Rails pre-loading for tests
  gem 'spring', '~> 0.0.10'
  # Clean database between each test example
  gem 'database_cleaner', '~> 1.1.1'
end

# Find and squish bugs easier with better_errors
group :development do
  gem 'better_errors', '~> 0.5.0'
  gem 'binding_of_caller', '~> 0.6.8'
end


# Deploy with Capistrano
gem 'capistrano', '~> 2.14.2'
gem 'rvm-capistrano', '~> 1.2.7'

# Use MySQL for production and development and testing on orithena
gem 'mysql2', '~> 0.3.11', group: [:production, :mysql_development, :mysql_test]

# Use SQLite for easy development and test when not on Orithena
gem 'sqlite3', '~> 1.3.7', group: [:development, :test]

gem 'json'

# Used in ProjectsController to create default CRUD methods
gem 'inherited_resources', '~> 1.3.1'

# User account management/authentication
gem 'devise', '~> 2.2.3'
# Needed to run devise:views at the least
gem 'therubyracer', '~> 0.11.3'

# DateTime parser
# Used to be able to process dates that are in a MM/DD/YY format for
# project end date
gem 'timeliness', '~> 0.3.7'

# Authorization
# The configuration file is found in app/models/ability.rb. It describes
# what permissions are allowed to certain types of users. It's enforced
# in controllers by authorize_resource call
gem 'cancan', '~> 1.6.9'

# Enumeration
# Allows easy enumeration of an attribute based on the a string column in
# the database. Also allows customizable behavior for different values of the attribute
gem 'classy_enum', '~> 3.2.0'

# Pictures
# Projects and Users both have pictures, which are managed by this
# Gem. We moved from PaperClip to this since PaperClip wouldn't let
# us cache the pictures when validation failed
gem 'carrierwave', '~> 0.8.0'
# Resizing in Carrierwave
# Dependency Carrierwave has to be able to resize pictures to more
# useful sizes
gem 'mini_magick', '~> 3.4'

# REST interaction
# Some Amazon interaction is the user through a browser, the rest
# is us talking directly to their API, we use HTTPParty for that.
gem 'httparty', '~> 0.10.2'

# GUID generation
# Our Amazon requests need a unique identifier which they refer
# to as a CallerReference. What better unique id than a GUID?
gem 'uuidtools', '~> 2.1.3'

# Caching gem
# Dalli is a Rails Memcached gem. We use caching for values around
# the site and on some fragments of pages.
# Memcache is a separate program from this gem that can be run by
# doing 'memcached' but should already be running as a daemon.
gem 'dalli', '~> 2.6.2'

# Web server for testing
gem 'unicorn', '~> 4.6.0'

# Task scheduler
# Configuration found at config/schedule.rb
# Used to run our custom rake tasks when needed
gem 'whenever', '~> 0.8.2'

# Bootstrap
# CSS framework used to make the site all nice and purty
gem 'twitter-bootstrap-rails', '~> 2.2.1'

# Less-Rails is a dependency for Bootstrap, which is written
# with the LESS stylesheet language instead of Rails' default SCSS
gem 'less-rails', '~> 2.2.6'

#Documentation generation
gem 'rdoc', '~> 3.4'

# Pagination gem
gem 'kaminari', '~> 0.14.1'
gem 'bootstrap-kaminari-views', '~> 0.0.2'

# Comments gem
gem 'acts_as_commentable_with_threading', '~> 1.1.2'

#YouTube Gem
gem 'youtube_it', '~> 2.1.13'

#rich text editor
gem 'ckeditor', '~> 4.0.2'

#ordering gem for Queues
gem 'acts_as_list', '~> 0.1.9'

# delayed gem (currently used when uploading videos)
gem 'delayed_job_active_record', '~> 0.3.3'
# used for running background proccess to run jobs
gem 'daemons', '~> 1.1.9'

# High Voltage is a gem that allows for 'static' pages that are
# processed by rails, so we can use embedded ruby.
gem 'high_voltage', '~> 1.2.1'

#judge is a gem used for client side validation.
gem 'judge', '~> 1.5.0'

# draper implements the presenter (decorator) pattern
# to help remove logic from views and view code from models.
# Github:
#   https://github.com/drapergem/draper
# RailsCast:
#   http://railscasts.com/episodes/286-draper
gem 'draper', '~> 1.1.0'
