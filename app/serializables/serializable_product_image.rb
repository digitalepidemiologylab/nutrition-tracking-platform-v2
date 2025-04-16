# frozen_string_literal: true

class SerializableProductImage < JSONAPI::Serializable::Resource
  type "product_images"

  has_one :product do
    linkage always: true
  end

  link :self do
    Rails.application.routes.url_helpers.url_for(@object.data)
  end
end
