# frozen_string_literal: true

module Api
  module V2
    class PushTokenPolicy < BasePolicy
      def create?
        user == record.user
      end

      def permitted_attributes
        [attributes: %i[platform token locale]]
      end
    end
  end
end
