ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])
require "bootsnap/setup" if File.exist?(File.expand_path("../tmp/cache", __dir__))
