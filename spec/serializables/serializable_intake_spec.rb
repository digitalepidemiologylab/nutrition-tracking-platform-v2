# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableIntake) do
  let(:intake) { create(:intake) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableIntake, we need to set the `_class` mannually.
    described_class.new(
      object: intake,
      _class: {Annotation: SerializableAnnotation}
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id(intake.id)
    expect(serialized)
      .to have_jsonapi_attributes(:timezone, :consumed_at, :updated_at).exactly
    expect(serialized).to have_attribute(:timezone).with_value(intake.timezone)
    expect(serialized).to have_relationships(:annotation).exactly
  end
end
