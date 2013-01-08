# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

# Code coverage config. Has to be at the very top.
require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'

require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Ran into trouble with the default transactions. Since we're not using fixtures
  # anyway, we can just turn them off.
  config.use_transactional_fixtures = false
  # Let's use DatabaseCleaner instead -- it seems to be more consistent.
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  Capybara.server_port = 3999

  config.include(MailerMacros)
  config.before(:each) { reset_email }

  # Capybara uses a DSL to allow test cases to interact with web pages
  config.include Capybara::DSL

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
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
