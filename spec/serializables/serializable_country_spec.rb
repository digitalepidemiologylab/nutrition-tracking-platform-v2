# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableCountry) do
  let(:country) { create(:country) }
  let(:serialized) do
    described_class.new(object: country).as_jsonapi
  end

  it do
    expect(serialized).to have_id(country.id)
    expect(serialized).to have_jsonapi_attributes(:name).exactly
    expect(serialized).to have_attribute(:name).with_value(country.name)
  end
end
