# frozen_string_literal: true

module HasTimezone
  extend ActiveSupport::Concern

  included do
    validates :timezone, presence: true, timezone: true

    before_validation :clean_timezone

    def clean_timezone
      self.timezone = Timezones::CleanerService.new(timezone).call
    end
  end
end
