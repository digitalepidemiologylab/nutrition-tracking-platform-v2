# frozen_string_literal: true

class SerializableDishImage < JSONAPI::Serializable::Resource
  type "dish_images"

  has_one :dish do
    linkage always: true
  end

  link :self do
    Rails.application.routes.url_helpers.url_for(@object.data)
  end
end
