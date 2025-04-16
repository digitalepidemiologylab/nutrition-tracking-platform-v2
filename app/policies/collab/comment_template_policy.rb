# frozen_string_literal: true

module Collab
  class CommentTemplatePolicy < BasePolicy
    def index?
      collaborator.admin?
    end

    def show?
      index?
    end

    def new?
      index?
    end

    def create?
      index?
    end

    def edit?
      index?
    end

    def update?
      index?
    end

    def destroy?
      index?
    end

    def permitted_attributes
      translated_attributes_for(:title) + translated_attributes_for(:message)
    end

    class Scope < Scope
      def resolve
        scope.all
      end
    end
  end
end
