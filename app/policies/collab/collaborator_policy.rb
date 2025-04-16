# frozen_string_literal: true

module Collab
  class CollaboratorPolicy < BasePolicy
    def index?
      collaborator.admin?
    end

    def permitted_attributes
      %i[email name timezone]
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          scope.joins(:collaborations).merge(CollaborationPolicy::Scope.new(collaborator, Collaboration).resolve)
        end
      end
    end
  end
end
