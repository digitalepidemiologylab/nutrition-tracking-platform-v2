# frozen_string_literal: true

class Collaboration < ApplicationRecord
  has_paper_trail

  enum role: {manager: "manager", annotator: "annotator"}

  belongs_to :collaborator, inverse_of: :collaborations
  belongs_to :cohort, inverse_of: :collaborations

  validates :role, inclusion: {in: roles.keys}
  validates :collaborator_id, uniqueness: {scope: :cohort_id, message: :already_in_cohort}

  scope :active, -> { where(deactivated_at: nil).or(where("deactivated_at > ?", Time.current)) }

  def deactivate
    update(deactivated_at: Time.current)
  end

  def reactivate
    update(deactivated_at: nil)
  end

  def deactivated?
    deactivated_at.present?
  end
end
