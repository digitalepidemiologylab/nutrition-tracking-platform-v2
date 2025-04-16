# frozen_string_literal: true

module Collab
  module Collaborators
    class TokenPolicy < BasePolicy
      def create?
        collaborator.admin? || collaborator == record
      end

      def destroy?
        create?
      end
    end
  end
end
