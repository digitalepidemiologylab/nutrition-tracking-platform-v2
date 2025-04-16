# frozen_string_literal: true

module Collab
  class WebauthnCredentialPolicy < BasePolicy
    def new?
      true
    end

    def create?
      new?
    end

    def destroy?
      collaborator.admin? || collaborator == record.collaborator
    end

    class Scope < Scope
      def resolve
        if collaborator.admin?
          scope.all
        else
          scope.where(collaborator: collaborator)
        end
      end
    end
  end
end
