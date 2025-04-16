# frozen_string_literal: true

class Intake < ApplicationRecord
  include HasTimezone

  has_paper_trail(
    on: %i[destroy],
    meta: {
      user_id: proc { |intake| intake.annotation.dish.user_id }
    }
  )

  belongs_to :annotation, inverse_of: :intakes

  validates :id, uniqueness: {case_sensitive: false}
  validates :consumed_at, presence: true, comparison: {less_than_or_equal_to: proc { 1.hour.from_now }, allow_nil: true, message: :less_than_or_equal_to_1_hour_from_now}
  validate :consumed_at_during_participation

  after_destroy_commit :destroy_annotation_if_no_intakes

  private def destroy_annotation_if_no_intakes
    return if annotation.intakes.exists?

    annotation.destroy!
  end

  private def consumed_at_during_participation
    return if consumed_at.nil? ||
      annotation&.participation.nil? ||
      consumed_at.between?(annotation.participation.started_at, (annotation.participation.ended_at || Time.current))

    errors.add(:consumed_at, :during_participation)
  end
end
