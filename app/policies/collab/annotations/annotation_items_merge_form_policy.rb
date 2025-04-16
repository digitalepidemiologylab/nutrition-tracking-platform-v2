# frozen_string_literal: true

module Collab
  module Annotations
    class AnnotationItemsMergeFormPolicy < BasePolicy
      def create?
        Collab::AnnotationPolicy.new(collaborator, record.annotation).update?
      end

      def permitted_attributes
        [annotation_item_ids: []]
      end
    end
  end
end
