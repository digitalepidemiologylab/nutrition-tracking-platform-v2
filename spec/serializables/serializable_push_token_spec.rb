# frozen_string_literal: true

require "rails_helper"

RSpec.describe(SerializablePushToken) do
  let(:push_token) { build_stubbed(:push_token, :android, id: Faker::Internet.uuid, locale: "fr") }
  let(:serialized) do
    # As we use `linkage always: true` in SerializablePushToken, we need to set the `_class` mannually.
    described_class.new(
      object: push_token,
      _class: {User: SerializableUser}
    ).as_jsonapi
  end

  it do
    expect(serialized).to have_id(push_token.id)
    expect(serialized).to have_type("push_tokens")
    expect(serialized)
      .to have_jsonapi_attributes(:platform, :token, :locale).exactly
    expect(serialized).to have_attribute(:platform).with_value("android")
    expect(serialized).to have_attribute(:locale).with_value("fr")
    expect(serialized).to have_relationships(:user).exactly
  end
end
