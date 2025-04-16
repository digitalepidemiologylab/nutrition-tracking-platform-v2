# frozen_string_literal: true

class Participation < ApplicationRecord
  has_paper_trail on: %i[destroy]

  belongs_to :cohort, inverse_of: :participations
  belongs_to :user, inverse_of: :participations, optional: true
  has_many :annotations, inverse_of: :participation, dependent: :destroy
  has_many :intakes, through: :annotations

  validates :key, presence: true, uniqueness: true
  validates :user_id, uniqueness: {allow_nil: true, scope: :cohort_id}
  validate :not_overlapping_other_participations
  validate :overlapping_intakes

  after_initialize :set_key
  before_save :set_associated_at, if: -> { will_save_change_to_user_id?(from: nil) }

  encrypts :key, deterministic: true

  scope :overlapped_by, ->(participation) {
    where.not(id: participation.id)
      .where(
        "
        (
          COALESCE(:started_at, '-infinity')::TIMESTAMP,
          COALESCE(:ended_at, 'infinity')::TIMESTAMP
        )
        OVERLAPS (started_at, ended_at)",
        started_at: participation.started_at,
        ended_at: participation.ended_at
      )
  }

  def set_associated_at
    current_time = Time.current
    self.associated_at = current_time
    self.started_at ||= current_time
  end

  private def set_key
    return if key.present?

    self.key = loop do
      key = SecureRandom.base58(9)
      break key unless self.class.exists?(key: key)
    end
  end

  private def not_overlapping_other_participations
    return if user.nil?

    overlapped_participations = user.participations.overlapped_by(self)
    return if overlapped_participations.none?

    errors.add(:base, :overlap)
  end

  private def overlapping_intakes
    min_consumed_at, max_consumed_at = intakes.pick("MIN(consumed_at)", "MAX(consumed_at)")
    return if min_consumed_at.nil? || # If min is nil, max must be too; intakes empty
      ((started_at.nil? || min_consumed_at >= started_at) && (ended_at.nil? || max_consumed_at <= ended_at))

    errors.add(:base, :intakes_outside_participation)
  end
end
