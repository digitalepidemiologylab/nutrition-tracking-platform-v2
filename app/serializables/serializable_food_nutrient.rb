# frozen_string_literal: true

class SerializableFoodNutrient < JSONAPI::Serializable::Resource
  type "food_nutrients"

  belongs_to :food do
    linkage always: true
  end

  belongs_to :nutrient do
    linkage always: true
  end

  attributes :per_hundred
end
