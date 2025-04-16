# frozen_string_literal: true

# This allows us to use the `render jsonapi_errors:` from jsonapi-rails
# To remove when the gem will be updated to support Rails 7.0
class ActiveModel::Errors
  alias_method :keys, :attribute_names
end
