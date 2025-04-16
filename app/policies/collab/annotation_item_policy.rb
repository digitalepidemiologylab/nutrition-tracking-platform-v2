# frozen_string_literal: true

module Collab
  class AnnotationItemPolicy < BasePolicy
    def create?
      Collab::AnnotationPolicy.new(collaborator, record.annotation).annotatable?
    end

    def update?
      create?
    end

    def destroy?
      create?
    end

    def permitted_attributes
      [
        :id,
        :barcode,
        :food_id,
        :product_id,
        :present_quantity,
        :present_unit_id,
        :consumed_quantity,
        :consumed_unit_id,
        :polygons,
        :disable_kcal_in_range_validation
      ]
    end
  end
end
