# frozen_string_literal: true

module HasPasswordNotPwned
  extend ActiveSupport::Concern

  included do
    attribute :bypass_pwned_validation, :boolean, default: false

    # password minimal length validated by devise
    validates :password, not_pwned: {
      on_error: ->(record, error) { Sentry.capture_exception(error) },
      unless: :bypass_pwned_validation
    }
  end
end
