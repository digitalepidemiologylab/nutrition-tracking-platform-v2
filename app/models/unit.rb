# frozen_string_literal: true

class Unit < ApplicationRecord
  has_many :foods, inverse_of: :unit, dependent: :restrict_with_error
  has_many :nutrients, inverse_of: :unit, dependent: :restrict_with_error
  has_many :products, inverse_of: :unit, dependent: :restrict_with_error

  enum base_unit: {volume: "ml", mass: "g", energy: "kcal"}

  validates :base_unit, presence: true, inclusion: {in: base_units.keys, allow_nil: true}
  validates :factor, presence: true, numericality: {allow_nil: true}

  before_validation :cannot_change_id_after_persist

  # Set prepend to true to avoid PG::NotNullViolation errors
  before_destroy :abort_if_not_destroyable, prepend: true

  scope :g_and_ml, -> { where(id: %i[ml g]) }

  def destroyable?
    !base_unit?
  end

  def base_unit?
    return false if new_record?

    reload.id.in?(Unit.base_units.values)
  end

  private def cannot_change_id_after_persist
    return unless persisted? && id_changed?

    errors.add(:id, I18n.t("activerecord.errors.models.unit.attributes.id.not_changeable"))
  end

  private def abort_if_not_destroyable
    return if destroyable?

    errors.add(:base, I18n.t("activerecord.errors.models.unit.base.not_destroyable"))
    throw(:abort)
  end
end
