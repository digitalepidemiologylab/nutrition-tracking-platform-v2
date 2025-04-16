# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableProductNutrient) do
  let(:product_nutrient) { create(:product_nutrient) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableProductNutrient, we need to set the `_class` mannually.
    described_class.new(
      object: product_nutrient,
      _class: {
        Product: SerializableProduct,
        Nutrient: SerializableNutrient
      }
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id(product_nutrient.id)
    expect(serialized).to have_attribute(:per_hundred).with_value(product_nutrient.per_hundred)
    expect(serialized).to have_relationships(:product, :nutrient).exactly
  end
end
