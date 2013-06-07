require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

# This file is set up with Spork-Rails. Check it out at
# https://github.com/sporkrb/spork-rails

Spork.prefork do
  # The Spork.prefork block is run only once when the spork server is started.
  # You typically want to place most of your (slow) initializer code in here, in
  # particular, require'ing any 3rd-party gems that you don't normally modify
  # during development.
  #
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.


  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'

  # Code coverage config. Has to be at the very top.
  require 'simplecov'
  SimpleCov.start 'rails'

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/rails'
  require 'capybara/rspec'
  require 'cancan/matchers'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

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

    # Ran into trouble with the default transactions. Since we're not using fixtures
    # anyway, we can just turn them off.
    config.use_transactional_fixtures = false

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.include(MailerMacros)
    config.before(:each) do
      reset_email
      Timecop.return
      Warden.test_reset! if Warden.respond_to? :test_reset!
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

end

# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
Spork.each_run do
  FactoryGirl.reload

  puts 'Cleaning Database'
  # TODO: Change this to run the Rake task 'db:test:prepare',
  # which isn't dependent on the models we have defined in the
  # database.
  Group.delete_all
  Approval.delete_all
  Comment.delete_all
  Contribution.delete_all
  Update.delete_all
  Video.delete_all
  Project.delete_all
  User.delete_all
end

# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
