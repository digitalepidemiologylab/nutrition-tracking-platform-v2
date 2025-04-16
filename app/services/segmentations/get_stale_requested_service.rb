# frozen_string_literal: true

module Segmentations
  class GetStaleRequestedService
    def call
      current_time = Time.current
      range = current_time - 3.hours..current_time - 1.hour
      Segmentation.requested.where(updated_at: range)
    end
  end
end
