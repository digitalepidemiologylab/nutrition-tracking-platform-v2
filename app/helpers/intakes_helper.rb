# frozen_string_literal: true

module IntakesHelper
  def consumed_at_in_timezone(intake:)
    tag.span do
      datetime_with_zone(datetime: intake.consumed_at, timezone: intake.timezone)
    end
  end
end
