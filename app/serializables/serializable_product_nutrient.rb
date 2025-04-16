# frozen_string_literal: true

class SerializableProductNutrient < JSONAPI::Serializable::Resource
  type "product_nutrients"

  belongs_to :product do
    linkage always: true
  end

  belongs_to :nutrient do
    linkage always: true
  end

  attributes :per_hundred
end
