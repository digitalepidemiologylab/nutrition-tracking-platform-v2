# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableParticipation, :freeze_time) do
  let(:participation) { create(:participation) }
  let(:serialized) do
    # As we use `linkage always: true` in SerializableParticipation, we need to set the `_class` mannually.
    described_class.new(
      object: participation,
      _class: {
        Cohort: SerializableCohort,
        Annotation: SerializableAnnotation
      }
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id(participation.id)
    expect(serialized).to have_jsonapi_attributes(:key, :started_at, :ended_at).exactly
    expect(serialized).to have_attribute(:key).with_value(participation.key)
    expect(serialized).to have_attribute(:started_at).with_value(Time.current.iso8601(6))
    expect(serialized).to have_attribute(:ended_at).with_value(1.week.from_now.iso8601(6))
    expect(serialized).to have_relationships(:cohort, :annotations).exactly
  end
end
