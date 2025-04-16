# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableDish) do
  let(:dish) { create(:dish, :with_description, :with_annotation_item) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableDish, we need to set the `_class` mannually.
    described_class.new(
      object: dish,
      _class: {
        DishImage: SerializableDishImage,
        Annotation: SerializableAnnotation
      }
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id(dish.id)
    expect(serialized).to have_jsonapi_attributes(:description).exactly
    expect(serialized).to have_attribute(:description).with_value(dish.description)
    expect(serialized)
      .to have_relationships(:dish_image, :annotations).exactly
  end
end
