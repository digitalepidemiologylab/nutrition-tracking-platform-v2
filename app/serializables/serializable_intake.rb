# frozen_string_literal: true

class SerializableIntake < JSONAPI::Serializable::Resource
  type "intakes"

  has_one :annotation do
    linkage always: true
  end

  attribute :timezone
  attribute(:consumed_at) { @object.consumed_at.iso8601(6) }
  attribute(:updated_at) { @object.updated_at.iso8601(6) }
end
