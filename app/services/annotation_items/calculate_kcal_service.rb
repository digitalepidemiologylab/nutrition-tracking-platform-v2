# frozen_string_literal: true

module AnnotationItems
  class CalculateKcalService
    def initialize(annotation_item:)
      @annotation_item = annotation_item
      @kcal_nutrient = Nutrient.find_by(id: "energy_kcal")
    end

    def call
      energy_kcal
    end

    def energy_kcal
      return if (quantity = absolute_consumed_amount).blank? || @kcal_nutrient.nil?

      item_nutrient = case @annotation_item.item
      when Food
        @annotation_item.food.food_nutrients.find_by(nutrient: @kcal_nutrient)
      when Product
        @annotation_item.product.product_nutrients.find_by(nutrient: @kcal_nutrient)
      end
      return if (per_hundred = item_nutrient&.per_hundred).blank?

      (quantity * per_hundred / 100)
    end

    def absolute_consumed_amount
      quantity = @annotation_item.present_quantity
      unit = @annotation_item.present_unit
      if @annotation_item.consumed_quantity.present? && @annotation_item.consumed_unit.present?
        quantity = @annotation_item.consumed_quantity
        unit = @annotation_item.consumed_unit
      end
      return nil if quantity.blank? || unit.blank?

      quantity = (quantity * @annotation_item.consumed_percent / 100) if @annotation_item.consumed_percent.present?
      quantity * unit.factor
    end
  end
end
