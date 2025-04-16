# frozen_string_literal: true

class SerializableComment < JSONAPI::Serializable::Resource
  type "comments"

  has_one :annotation do
    linkage always: true
  end

  has_one :collaborator do
    linkage always: true
  end

  attribute(:message)
  attribute(:created_at) { @object.created_at.iso8601(6) }
end
