# frozen_string_literal: true

module AnnotationsHelper
  def last_consumed_at_in_timezone(annotation:)
    tag.span do
      datetime_with_zone(datetime: annotation.last_intake.consumed_at, timezone: annotation.last_intake.timezone)
    end
  end
end
