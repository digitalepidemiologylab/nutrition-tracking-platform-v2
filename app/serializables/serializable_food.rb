# frozen_string_literal: true

class SerializableFood < JSONAPI::Serializable::Resource
  type "foods"

  attribute :name

  has_many :food_nutrients do
    linkage always: true
  end
end
