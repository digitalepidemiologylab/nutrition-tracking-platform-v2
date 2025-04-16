# frozen_string_literal: true

module Collab
  class ProfilePolicy < BasePolicy
    def show?
      collaborator == record
    end

    def edit?
      update?
    end

    def update?
      collaborator == record
    end
  end
end
