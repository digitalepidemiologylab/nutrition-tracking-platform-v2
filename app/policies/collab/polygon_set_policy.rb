# frozen_string_literal: true

module Collab
  class PolygonSetPolicy < BasePolicy
    def update?
      Collab::AnnotationItemPolicy.new(collaborator, record.annotation_item).update?
    end

    def destroy?
      update?
    end

    def permitted_attributes
      [
        :polygons
      ]
    end
  end
end
