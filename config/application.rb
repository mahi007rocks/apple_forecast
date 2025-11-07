require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups) if defined?(Bundler)

module AppleForecast
  class Application < Rails::Application
    config.load_defaults 7.1

    config.time_zone = "UTC"
    config.eager_load_paths << Rails.root.join("app/services")
    config.eager_load_paths << Rails.root.join("app/view_models")
    config.i18n.available_locales = [:en]
    config.i18n.default_locale = :en
    config.generators do |g|
      g.test_framework :rspec
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.views false
    end
  end
end
