# frozen_string_literal: true

module Collab
  class FoodSetPolicy < BasePolicy
    def index?
      collaborator.admin?
    end

    def show?
      collaborator.admin?
    end

    def new?
      create?
    end

    def create?
      collaborator.admin?
    end

    def edit?
      update?
    end

    def update?
      collaborator.admin?
    end

    def destroy?
      collaborator.admin?
    end

    def permitted_attributes
      %i[cname] + translated_attributes_for(:name)
    end

    def permitted_sort_attributes
      %w[cname name created_at]
    end

    class Scope < Scope
      def resolve
        scope.all
      end
    end
  end
end
