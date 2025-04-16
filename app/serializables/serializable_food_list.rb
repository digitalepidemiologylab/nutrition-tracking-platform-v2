# frozen_string_literal: true

class SerializableFoodList < JSONAPI::Serializable::Resource
  type "food_lists"

  attributes(:name, :source, :version, :editable, :country_id)
end
