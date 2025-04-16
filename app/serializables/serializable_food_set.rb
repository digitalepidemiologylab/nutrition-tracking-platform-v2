# frozen_string_literal: true

class SerializableFoodSet < JSONAPI::Serializable::Resource
  type "food_sets"

  attribute :name
end
