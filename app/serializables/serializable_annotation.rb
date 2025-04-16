# frozen_string_literal: true

class SerializableAnnotation < JSONAPI::Serializable::Resource
  type "annotations"

  has_one :dish do
    linkage always: true
  end

  has_many :intakes do
    linkage always: true
  end

  has_many :annotation_items do
    linkage always: true
  end

  has_many :comments do
    linkage always: true
  end

  attribute :status
end
