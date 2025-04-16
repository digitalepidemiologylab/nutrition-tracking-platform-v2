# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyFoodRepo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(7.1)

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.time_zone = "UTC"

    # config.eager_load_paths << Rails.root.join("extras")

    # ViewComponent config
    config.view_component.preview_paths << Rails.root.join("lib/component_previews")
    config.view_component.preview_route = "/styleguide/components"

    config.middleware.use(Rack::Deflater)

    config.i18n.available_locales = %w[en fr de]
    config.i18n.default_locale = "en"
    config.i18n.fallbacks = %w[en fr de]

    config.exceptions_app = routes

    config.generators do |g|
      g.test_framework(:rspec, fixture: true)
      g.fixture_replacement(:factory_bot, dir: "spec/factories")
    end

    config.active_record.encryption.primary_key = ENV.fetch("PRIMARY_KEY")
    config.active_record.encryption.deterministic_key = ENV.fetch("DETERMINISTIC_KEY")
    config.active_record.encryption.key_derivation_salt = ENV.fetch("KEY_DERIVATION_SALT")

    # Don't wrap fields with errors in a `div.field_with_errors` element which often breaks the design
    config.action_view.field_error_proc = proc { |html_tag, instance| html_tag }

    config.active_job.queue_adapter = :sidekiq

    # By default, FactoryBot will refuse to generate Active Record primary key columns. Without additional configuration, an Active Record model treats a column named id as its primary key.
    # For example, defining an id attribute with add_attribute(:id), id { ... }, or sequence(:id) will raise a FactoryBot::AttributeDefinitionError.
    # The following config disable this behavior:
    config.factory_bot.reject_primary_key_attributes = false
  end
end
