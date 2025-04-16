# frozen_string_literal: true

class SerializableCountry < JSONAPI::Serializable::Resource
  type "countries"

  attribute :name
end
