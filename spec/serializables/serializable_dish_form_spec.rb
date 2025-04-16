# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableDishForm) do
  let(:dish_form) { create(:dish_form) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableDishForm, we need to set the `_class` mannually.
    described_class.new(
      object: dish_form,
      _class: {
        Dish: SerializableDish,
        DishImage: SerializableDishImage,
        Intake: SerializableIntake,
        Annotation: SerializableAnnotation,
        Product: SerializableProduct,
        ProductImage: SerializableProductImage
      }
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id("")
    expect(serialized).not_to have_jsonapi_attributes
    expect(serialized)
      .to have_relationships(:dish, :dish_image, :intake, :annotation, :product, :product_images).exactly
  end
end
