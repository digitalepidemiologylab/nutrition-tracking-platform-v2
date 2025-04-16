# frozen_string_literal: true

module Collab
  class JobLogPolicy < BasePolicy
    def index?
      collaborator.admin?
    end

    class Scope < Scope
      def resolve
        collaborator.admin? ? scope.all : scope.none
      end
    end
  end
end
