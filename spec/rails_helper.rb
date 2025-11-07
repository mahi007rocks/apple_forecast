# frozen_string_literal: true
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "webmock/rspec"

# Disable external network connections but allow localhost
WebMock.disable_net_connect!(allow_localhost: true)

# Load all support files
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Configure RSpec to use rack_test driver
  config.include RSpec::Rails::RequestExampleGroup, type: :request
  
  # Disable transactional fixtures as we're using rack_test
  config.use_transactional_fixtures = false
  
  # Configure test database cleaning strategy
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Configure test environment
  # (Removed host! to use default host)

  # Allow inferring spec types from file location
  config.infer_spec_type_from_file_location!

  # Filter Rails-specific gems from backtraces
  config.filter_rails_from_backtrace!
end
