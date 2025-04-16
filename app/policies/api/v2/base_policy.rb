# frozen_string_literal: true

module Api
  module V2
    class BasePolicy
      attr_reader :user, :record

      def initialize(user, record)
        raise Pundit::NotAuthorizedError, I18n.t("devise.failure.unauthenticated") if user.blank?

        @user = user
        @record = record
      end

      class Scope
        private attr_reader(:user, :scope)

        def initialize(user, scope)
          raise Pundit::NotAuthorizedError, I18n.t("devise.failure.unauthenticated") if user.blank?

          @user = user
          @scope = scope
        end
      end
    end
  end
end
