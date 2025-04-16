# frozen_string_literal: true

class Timezones::CleanerService
  def initialize(timezone)
    @timezone = timezone
  end

  def call
    return if @timezone.blank?

    # America/Ciudad_Juarez is used by iOS, but is not a valid timezone for Ruby's TZInfo, so we replace it
    # by America/Denver. About the choice of America/Denver see https://en.wikipedia.org/wiki/Time_in_Mexico
    return "America/Denver" if @timezone == "America/Ciudad_Juarez"

    unless TimezoneValidator.valid?(@timezone)
      Sentry.capture_message("Invalid timezone: #{@timezone}", level: :info)
      return "UTC"
    end

    @timezone
  end
end
