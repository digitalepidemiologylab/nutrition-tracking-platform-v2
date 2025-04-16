# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableDishImage) do
  let(:dish_image) { create(:dish_image) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableDishImage, we need to set the `_class` mannually.
    described_class.new(
      object: dish_image,
      _class: {Dish: SerializableDish}
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id(dish_image.id)
    expect(serialized).not_to have_jsonapi_attributes
    expect(serialized).to have_link(:self).with_value(url_for(dish_image.data))
    expect(serialized).to have_relationships(:dish).exactly
  end
end
