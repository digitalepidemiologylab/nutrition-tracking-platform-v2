# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializableUser) do
  let(:user) { create(:user) }
  let(:serialized) do
    described_class.new(object: user).as_jsonapi
  end

  it do
    expect(serialized).to have_id(user.id)
    expect(serialized)
      .to have_jsonapi_attributes(:email, :anonymous, :dishes_private).exactly
    expect(serialized).to have_attribute(:email).with_value(user.email)
  end
end
