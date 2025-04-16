# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.2"

gem "rails", "~> 7.1.2"

# Database
gem "pg", "~> 1.5"
gem "redis"

# Server
gem "puma", "~> 6.4"

# Authentication
gem "devise"
gem "devise_invitable"
gem "devise_token_auth", github: "lynndylanhurley/devise_token_auth", branch: "master"
gem "webauthn"

# Authentication security
gem "pwned"

# Authorization
gem "pundit"

# Serialization
gem "jsonapi-rails"

# Front stuff
gem "cssbundling-rails"
gem "jsbundling-rails"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"

# ViewComponent
gem "view_component"
gem "lookbook" # Need to be after the `view_component` gem

# http calls
gem "httparty"

# I18n
gem "mobility"

# Pagination
gem "pagy"

# Logging
gem "sentry-ruby"
gem "sentry-rails"

# Factories and faking (also required in production for seeding)
gem "factory_bot_rails"
gem "faker"

# ActiveStorage and Image processing
gem "aws-sdk-s3"
gem "image_processing"

# API documentation
gem "rswag-api"
gem "rswag-ui"

# Background jobs
gem "sidekiq"
gem "sidekiq-cron"

# push notifications
gem "apnotic"
gem "fcm"

# Search
gem "pg_search"

# Soft delete, versioning
gem "paper_trail"

# State machine
gem "aasm"
gem "after_commit_everywhere"

# User agent detection
gem "useragent", "1.5.3", github: "art19/useragent"

# Misc
gem "bootsnap", require: false
gem "rack-cors"
gem "redcarpet"
gem "rubyzip", "~> 2.3.2"
gem "acts_as_list"

# Code coverage
gem "coverband"

group :development, :test do
  gem "awesome_print"
  gem "better_html"
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "erb_lint", require: false
  gem "parallel_tests"
  gem "rspec-rails"
  gem "rswag-specs"
  gem "rubocop-rails_config", require: false
  gem "rubocop-rspec", require: false
  gem "standard"
end

group :development do
  gem "active_record_doctor"
  gem "brakeman"
  gem "i18n-tasks"
  gem "letter_opener_web"
  gem "pg_query"
  gem "prosopite"
  gem "rack-mini-profiler", require: false
  gem "web-console"
end

group :test do
  gem "capybara"
  # Use master branch as latest release has a bug affecting have_type: jsonapi-rb/jsonapi-rspec#29
  gem "jsonapi-rspec", github: "jsonapi-rb/jsonapi-rspec", branch: "master"
  gem "rspec-retry"
  gem "selenium-webdriver", "~> 4.15"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "test-prof"
  gem "webmock"
end
