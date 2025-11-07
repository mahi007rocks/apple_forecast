source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.3"

gem "rails", "~> 7.1"
gem "bootsnap", require: false

group :development, :test do
  gem "sqlite3", "~> 1.6"
  gem "rspec-rails", "~> 6.0"
  gem "webmock", "~> 3.19"
  gem "dotenv-rails"
end

group :production do
  gem "pg", "~> 1.5"
end

gem "faraday", "~> 2.9"
gem "redis", "~> 5.0"
gem "geocoder", "~> 1.8"
