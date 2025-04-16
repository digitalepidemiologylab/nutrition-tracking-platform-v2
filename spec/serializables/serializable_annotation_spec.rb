# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableAnnotation) do
  let(:annotation) { create(:annotation, :with_annotation_item) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableAnnotation, we need to set the `_class` mannually.
    described_class.new(
      object: annotation,
      _class: {
        Dish: SerializableDish,
        Comment: SerializableComment,
        AnnotationItem: SerializableAnnotationItem,
        Intake: SerializableIntake
      }
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id(annotation.id)
    expect(serialized).to have_jsonapi_attributes(:status).exactly
    expect(serialized).to have_attribute(:status).with_value(annotation.status)
    expect(serialized).to have_relationships(:dish, :annotation_items, :comments, :intakes).exactly
  end
end
