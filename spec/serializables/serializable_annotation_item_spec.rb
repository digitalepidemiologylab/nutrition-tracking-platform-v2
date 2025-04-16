# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableAnnotationItem) do
  let(:annotation_item) { create(:annotation_item) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableAnnotationItem, we need to set the `_class` mannually.
    described_class.new(
      object: annotation_item,
      _class: {
        Annotation: SerializableAnnotation,
        Food: SerializableFood,
        Product: SerializableProduct
      }
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id(annotation_item.id)
    expect(serialized).to have_jsonapi_attributes(:consumed_quantity, :consumed_unit_id).exactly
    expect(serialized).to have_relationships(:annotation, :food, :product).exactly
  end
end
