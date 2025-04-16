# frozen_string_literal: true

class SerializableDishForm < JSONAPI::Serializable::Resource
  type "dish_forms"

  has_one :annotation do
    linkage always: true
  end

  has_one :dish do
    linkage always: true
  end

  has_one :dish_image do
    linkage always: true
  end

  has_one :intake do
    linkage always: true
  end

  has_one :product do
    linkage always: true
  end

  has_many :product_images do
    linkage always: true
  end
end
