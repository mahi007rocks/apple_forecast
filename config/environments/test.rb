require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Remove HostAuthorization middleware to prevent 403 errors in tests
  config.middleware.delete ActionDispatch::HostAuthorization
  # Allow all hosts in test to avoid HostAuthorization 403 errors
  config.hosts << nil
  # Test-specific settings
  config.cache_classes = true
  config.eager_load = ENV["CI"].present?
  config.serve_static_files = true

  # Error handling and debugging
  config.consider_all_requests_local = true
  config.action_dispatch.show_exceptions = false
  config.active_support.deprecation = :stderr
  config.active_support.test_order = :random

  # Security settings for test environment
  config.action_controller.allow_forgery_protection = false
  config.action_controller.forgery_protection_origin_check = false
  config.hosts.clear if config.respond_to?(:hosts)

  # Caching configuration
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Public file server settings
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=3600"
  }

  # Basic security headers
  config.action_dispatch.default_headers = {
    'X-Frame-Options' => 'SAMEORIGIN',
    'X-XSS-Protection' => '1; mode=block',
    'X-Content-Type-Options' => 'nosniff'
  }
end
