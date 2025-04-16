# frozen_string_literal: true

class JobLog < ApplicationRecord
  include AASM

  aasm column: :status, no_direct_assignment: true, whiny_persistence: true do
    state :initial, initial: true
    state :processing
    state :failed
    state :succeeded

    event :process do
      transitions from: %i[initial failed succeeded], to: :processing

      success do
        update(start_at: Time.current, end_at: nil)
      end
    end

    event :fail do
      transitions from: :processing, to: :failed

      success do |exception|
        attrs = {end_at: Time.current}
        attrs[:logs] = "#{exception.message}\n#{exception.backtrace.join("\n")}" if exception
        update!(attrs)
      end
    end

    event :succeed do
      transitions from: :processing, to: :succeeded

      success do
        update!(logs: nil, end_at: Time.current)
      end
    end
  end

  validates :job_id, :job_name, presence: true
  validates :end_at, comparison: {greater_than_or_equal_to: :start_at, if: :start_at, allow_nil: true, message: :greater_than_start_at}
end
