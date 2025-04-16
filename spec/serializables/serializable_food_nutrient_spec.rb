# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableFoodNutrient) do
  let(:food_nutrient) { create(:food_nutrient) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableFoodNutrient, we need to set the `_class` mannually.
    described_class.new(
      object: food_nutrient,
      _class: {
        Food: SerializableFood,
        Nutrient: SerializableNutrient
      }
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id(food_nutrient.id)
    expect(serialized).to have_attribute(:per_hundred).with_value(food_nutrient.per_hundred)
    expect(serialized).to have_relationships(:food, :nutrient).exactly
  end
end
