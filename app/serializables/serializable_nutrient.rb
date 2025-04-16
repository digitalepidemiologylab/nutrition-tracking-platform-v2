# frozen_string_literal: true

class SerializableNutrient < JSONAPI::Serializable::Resource
  type "nutrients"

  attribute :name

  belongs_to :unit do
    linkage always: true
  end
end
