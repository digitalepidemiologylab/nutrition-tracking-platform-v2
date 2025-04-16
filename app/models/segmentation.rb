# frozen_string_literal: true

class Segmentation < ApplicationRecord
  include AASM

  MAX_STALE_TIME = 48.hours
  MIN_STALE_TIME = 1.hour

  belongs_to :annotation, inverse_of: :segmentation
  belongs_to :dish_image, inverse_of: :segmentations
  belongs_to :segmentation_client, inverse_of: :segmentations

  # See doc/segmentation_statuses.md for documentation on the statuses.
  aasm column: :status, no_direct_assignment: true, whiny_persistence: true do
    state :initial, initial: true
    state :requested
    state :received
    state :processed
    state :error

    event :request do
      transitions from: :initial, to: :requested

      success do
        annotation.send_to_segmentation_service!
      end
    end

    event :receive do
      transitions from: :requested, to: :received
    end

    event :process do
      transitions from: :received, to: :processed

      success do
        annotation.open_annotation!
        clear_response_body
      end
    end

    event :fail do
      before do |error|
        next unless error

        self.error_kind = error
      end

      transitions from: %i[initial requested received processed], to: :error, guard: :error_kind_set?

      success do
        annotation.open_annotation! unless annotation.annotatable?
        clear_response_body
      end
    end
  end

  after_create_commit :start_segmentation

  delegate :has_image?, to: :annotation

  scope :stale_requested, lambda {
    requested.where(started_at: MAX_STALE_TIME.ago..MIN_STALE_TIME.ago)
  }

  private def start_segmentation
    Segmentations::StartJob.perform_later(segmentation: self)
  end

  private def error_kind_set?
    error_kind.present?
  end

  private def clear_response_body
    update!(response_body: nil)
  end
end
