# frozen_string_literal: true

module Collab
  class SegmentationClientPolicy < BasePolicy
    def index?
      true
    end

    def show?
      true
    end

    def edit?
      update?
    end

    def update?
      collaborator.admin?
    end

    def destroy?
      collaborator.admin? && associations_empty?
    end

    private def associations_empty?
      return true unless record.is_a?(SegmentationClient)

      has_manies = SegmentationClient.reflect_on_all_associations(:has_many).map(&:name)
      has_manies.all? { |association_name| record.public_send(association_name).empty? }
    end

    class Scope < Scope
      def resolve
        scope.all
      end
    end
  end
end
