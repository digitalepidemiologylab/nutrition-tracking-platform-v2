# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableUnit) do
  let(:unit) { build(:unit) }
  let(:serialized) { described_class.new(object: unit).as_jsonapi }

  it do
    expect(serialized).to have_id(unit.id)
  end
end
