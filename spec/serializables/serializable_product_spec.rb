# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableProduct) do
  let(:product) do
    create(:product, :with_name, :with_unit, :with_portion_quantity, :with_product_images, :with_product_nutrients)
  end
  let(:serialized) do
    # As we use `linkage always: true` in SerializableProduct, we need to set the `_class` mannually.
    described_class.new(
      object: product,
      _class: {
        ProductNutrient: SerializableProductNutrient,
        ProductImage: SerializableProductImage
      }
    ).as_jsonapi
  end

  before { create_base_units }

  it do
    expect(serialized).to have_id(product.id)
    expect(serialized)
      .to have_jsonapi_attributes(:barcode, :name).exactly
    expect(serialized).to have_attribute(:barcode).with_value(product.barcode)
    expect(serialized).to have_attribute(:name).with_value(product.name)
    expect(serialized).to have_relationships(:product_nutrients, :product_images).exactly
  end
end
