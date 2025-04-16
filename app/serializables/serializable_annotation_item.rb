# frozen_string_literal: true

class SerializableAnnotationItem < JSONAPI::Serializable::Resource
  type "annotation_items"

  belongs_to :annotation do
    linkage always: true
  end

  belongs_to :food do
    linkage always: true
  end

  belongs_to :product do
    linkage always: true
  end

  attribute :consumed_quantity do
    @object.calculated_consumed_quantity
  end

  attribute :consumed_unit_id do
    @object.consumed_unit_id || @object.present_unit_id
  end
end
