# frozen_string_literal: true

class KcalInRangeValidator < ActiveModel::Validator
  def validate(record)
    return if record.consumed_kcal.blank? ||
      !perform_validation?(record) ||
      !kcal_out_of_range?(record)

    record.errors.add(
      :consumed_kcal,
      I18n.t("activerecord.errors.models.annotation_item.attributes.consumed_kcal.out_of_range")
    )
  end

  private def perform_validation?(record)
    food = record.food
    (food&.kcal_min.present? || food&.kcal_max.present?)
  end

  private def kcal_out_of_range?(record)
    food = record.food
    food.kcal_min.present? && record.consumed_kcal < food.kcal_min ||
      food.kcal_max.present? && record.consumed_kcal > food.kcal_max
  end
end
