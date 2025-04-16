# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableFoodSet) do
  let(:food_set) { create(:food_set) }
  let(:serialized) do
    described_class.new(object: food_set).as_jsonapi
  end

  it do
    expect(serialized).to have_id(food_set.id)
    expect(serialized).to have_jsonapi_attributes(:name).exactly
    expect(serialized).to have_attribute(:name).with_value(food_set.name)
  end
end
