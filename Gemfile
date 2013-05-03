source 'http://rubygems.org'

gem 'rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'jquery-rails'

# RSpec is our testing framework, at the heart of our tests
gem 'rspec-rails', group: [:test, :mysql_test, :mysql_development, :development]

# Testing gems!
group :test, :mysql_test do
  # Pretty printed test output
  gem 'turn', require: false
  # Factory Girl is used in place of fixtures
  # to make test objects for our tests to use
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  # Guard automatically runs tests when you save a file
  # Run it by doing 'bundle exec guard'
  gem 'guard-rspec'
  # Spork helps speed up guard and rspec by caching the Rails
  # application between runs, instead of loading the application before
  # each run of the test suite.
  gem 'spork-rails'
  gem 'guard-spork'
  # rb-fsevent listens to OSX file save events. Helps Guard
  # detect file changes on macs.
  gem 'rb-fsevent'
  # Capybara is used for integration testing, the stuff you
  # find in the spec/requests folder
  gem 'capybara'
  # Driver for testing Javascript with Capybara
  gem 'capybara-webkit'
  # Open page for examination during a test - used for debugging failing tests.
  gem 'launchy'
  # Code coverage!
  gem 'simplecov', require: false

  # Test time-sensitive behavior without having to wait days
  gem 'timecop'
end

# Find and squish bugs easier with better_errors
group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end


# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

# Use MySQL for production and development and testing on orithena
gem 'mysql2', group: [:production, :mysql_development, :mysql_test]

# Use SQLite for easy development and test when not on Orithena
gem 'sqlite3', group: [:development, :test]

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

# Enumeration
# Allows easy enumeration of an attribute based on the a string column in
# the database. Also allows customizable behavior for different values of the attribute
gem 'classy_enum'

# Pictures
# Projects and Users both have pictures, which are managed by this
# Gem. We moved from PaperClip to this since PaperClip wouldn't let
# us cache the pictures when validation failed
gem 'carrierwave'
# Resizing in Carrierwave
# Dependency Carrierwave has to be able to resize pictures to more
# useful sizes
gem 'mini_magick'

# REST interaction
# Some Amazon interaction is the user through a browser, the rest
# is us talking directly to their API, we use HTTPParty for that.
gem 'httparty'

# GUID generation
# Our Amazon requests need a unique identifier which they refer
# to as a CallerReference. What better unique id than a GUID?
gem 'uuidtools'

# Caching gem
# Dalli is a Rails Memcached gem. We use caching for values around
# the site and on some fragments of pages.
# Memcache is a separate program from this gem that can be run by
# doing 'memcached' but should already be running as a daemon.
gem 'dalli'

# Web server for testing
gem 'unicorn'

# Task scheduler
# Configuration found at config/schedule.rb
# Used to run our custom rake tasks when needed
gem 'whenever'

# Bootstrap
# CSS framework used to make the site all nice and purty
gem 'twitter-bootstrap-rails'

# Less-Rails is a dependency for Bootstrap, which is written
# with the LESS stylesheet language instead of Rails' default SCSS
gem 'less-rails'

#Documentation generation
gem 'rdoc'

# Pagination gem
gem 'kaminari'
gem 'bootstrap-kaminari-views'

# Comments gem
gem 'acts_as_commentable_with_threading'

#YouTube Gem
gem 'youtube_it'

#rich text editor
gem 'ckeditor'

#ordering gem for Queues
gem 'acts_as_list'

# delayed gem (currently used when uploading videos)
gem 'delayed_job_active_record'
# used for running background proccess to run jobs
gem 'daemons'

# High Voltage is a gem that allows for 'static' pages that are
# processed by rails, so we can use embedded ruby.
gem 'high_voltage'

#judge is a gem used for client side validation.
gem 'judge'

# draper implements the presenter (decorator) pattern
# to help remove logic from views and view code from models.
# Github:
#   https://github.com/drapergem/draper
# RailsCast:
#   http://railscasts.com/episodes/286-draper
gem 'draper'
