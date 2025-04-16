# frozen_string_literal: true

module Collab
  class BasePolicy
    attr_reader :collaborator, :record

    def initialize(collaborator, record)
      raise Pundit::NotAuthorizedError, I18n.t("devise.failure.unauthenticated") if collaborator.blank?

      @collaborator = collaborator
      @record = record
    end

    # The `cohort` argument can either be:
    # - a single cohort
    # - a collection of cohorts
    # - `:any` for any cohorts
    def manager?(cohort:)
      has_role?(cohort: cohort, role: :manager)
    end

    # The `cohort` argument can either be:
    # - a single cohort
    # - a collection of cohorts
    # - `:any` for any cohorts
    def annotator?(cohort:)
      has_role?(cohort: cohort, role: :annotator)
    end

    # The `cohort` argument can either be:
    # - a single cohort
    # - a collection of cohorts
    # - `:any` for any cohorts
    def manager_or_annotator?(cohort:)
      has_role?(cohort: cohort, role: %i[manager annotator])
    end

    def translated_attributes_for(attribute)
      I18n.available_locales.map { |locale| :"#{attribute}_#{locale}" }
    end

    private def has_role?(cohort:, role:)
      return collaborator.collaborations.exists?(role: role) if cohort == :any

      collaborator.collaborations.exists?(cohort: cohort, role: role)
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
