# frozen_string_literal: true

# Remove "Completed JSON API rendering" from the logs
ActiveSupport::Notifications.unsubscribe("parse.jsonapi-rails")
ActiveSupport::Notifications.unsubscribe("render.jsonapi-rails")
