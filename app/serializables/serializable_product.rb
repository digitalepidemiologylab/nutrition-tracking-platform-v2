# frozen_string_literal: true

class SerializableProduct < JSONAPI::Serializable::Resource
  type "products"

  has_many :product_nutrients do
    linkage always: true
  end

  has_many :product_images do
    linkage always: true
  end

  attributes :barcode, :name
end
