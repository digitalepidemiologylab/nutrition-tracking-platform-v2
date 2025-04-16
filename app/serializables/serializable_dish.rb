# frozen_string_literal: true

class SerializableDish < JSONAPI::Serializable::Resource
  type "dishes"

  has_one :dish_image do
    linkage always: true
  end

  has_many :annotations do
    linkage always: true
  end

  attribute :description
end
