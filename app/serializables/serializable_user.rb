# frozen_string_literal: true

class SerializableUser < JSONAPI::Serializable::Resource
  type "users"

  attribute :dishes_private
  attribute :email
  attribute :anonymous
end
