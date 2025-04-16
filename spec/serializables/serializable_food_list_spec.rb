# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableFoodList) do
  let(:food_list) { create(:food_list) }
  let(:serialized) do
    described_class.new(object: food_list).as_jsonapi
  end

  it do
    expect(serialized).to have_id(food_list.id)
    expect(serialized).to have_jsonapi_attributes(:name, :source, :version, :editable, :country_id).exactly
    expect(serialized).to have_attribute(:name).with_value(food_list.name)
  end
end
