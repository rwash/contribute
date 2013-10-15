require 'rubygems'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

# Code coverage config. Has to be at the very top.
require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'cancan/matchers'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("spec/matchers/**/*.rb")].each {|f| require f}

# Require lib files
Dir[Rails.root.join("lib/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  DatabaseCleaner.strategy = :truncation

  config.include(MailerMacros)
  config.before(:each) do
    reset_email
    Timecop.return
    Warden.test_reset! if Warden.respond_to? :test_reset!
    DatabaseCleaner.clean
  end

  # Capybara uses a DSL to allow test cases to interact with web pages
  config.include Capybara::DSL

  # Use capybara-webkit gem to run Javascript tests through the
  # Capybara interface
  Capybara.javascript_driver = :webkit

  # Allows the use of FactoryGirl methods without the namespace
  # old:
  #     FactoryGirl.create(:user)
  #
  # new:
  #     create(:user)
  config.include FactoryGirl::Syntax::Methods

  # The following options allow a developer to focus on specific tests,
  # excluding the rest of the test suite. To do so,
  # on any `describe`, `context`, or `it` block, add a :focus argument
  #
  # Example:
  #
  #   describe ProjectsController, :focus do
  #     ....
  #   end
  #
  # Rspec will then only run the tests that are being focused on.
  # To run all tests again, remove the focus from all tests.
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
