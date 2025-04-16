# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableProductImage) do
  let(:product_image) { create(:product_image) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableProductImage, we need to set the `_class` mannually.
    described_class.new(
      object: product_image,
      _class: {Product: SerializableProduct}
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id(product_image.id)
    expect(serialized).not_to have_jsonapi_attributes
    expect(serialized).to have_link(:self).with_value(url_for(product_image.data))
    expect(serialized).to have_relationships(:product).exactly
  end
end
