# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableNutrient) do
  let(:nutrient) { build(:nutrient) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableNutrient, we need to set the `_class` mannually.
    described_class.new(object: nutrient, _class: {Unit: SerializableUnit}).as_jsonapi
  end

  it do
    expect(serialized).to have_id(nutrient.id)
    expect(serialized).to have_attribute(:name).with_value(nutrient.name)
    expect(serialized).to have_relationships(:unit).exactly
  end
end
