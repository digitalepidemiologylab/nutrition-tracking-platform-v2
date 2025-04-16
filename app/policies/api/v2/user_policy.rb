# frozen_string_literal: true

module Api
  module V2
    class UserPolicy < BasePolicy
      def permitted_attributes
        [:type, attributes: %i[email password password_confirmation dishes_private]]
      end
    end
  end
end
