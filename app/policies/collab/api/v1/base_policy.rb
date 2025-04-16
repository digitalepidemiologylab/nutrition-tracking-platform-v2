# frozen_string_literal: true

module Collab
  module Api
    module V1
      class BasePolicy
        attr_reader :collaborator, :record

        def initialize(collaborator, record)
          raise Pundit::NotAuthorizedError, I18n.t("devise.failure.unauthenticated") if collaborator.blank?

          @collaborator = collaborator
          @record = record
        end

        class Scope
          private attr_reader(:collaborator, :scope)

          def initialize(collaborator, scope)
            raise Pundit::NotAuthorizedError, I18n.t("devise.failure.unauthenticated") if collaborator.blank?

            @collaborator = collaborator
            @scope = scope
          end
        end
      end
    end
  end
end
