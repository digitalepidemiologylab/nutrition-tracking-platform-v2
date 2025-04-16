# frozen_string_literal: true

module Collab
  module Users
    class AnonymizeServicePolicy < BasePolicy
      def update?
        !record.user.anonymous? && collaborator.admin?
      end
    end
  end
end
