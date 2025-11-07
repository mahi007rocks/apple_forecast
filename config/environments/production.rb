require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  config.log_level = :info
  config.log_tags = [:request_id]

  config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"), expires_in: 30.minutes }
  config.action_controller.perform_caching = true

  config.active_support.deprecation = :notify
  config.active_record.dump_schema_after_migration = false

  config.force_ssl = false
end
