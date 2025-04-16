# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableFood) do
  let(:food) { create(:food) }
  let(:serialized) do
    described_class.new(object: food).as_jsonapi
  end

  it do
    expect(serialized).to have_id(food.id)
    expect(serialized).to have_jsonapi_attributes(:name).exactly
    expect(serialized).to have_attribute(:name).with_value(food.name)
    expect(serialized).to have_relationships(:food_nutrients).exactly
  end
end
