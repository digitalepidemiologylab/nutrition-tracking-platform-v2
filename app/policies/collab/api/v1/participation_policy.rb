# frozen_string_literal: true

module Collab
  module Api
    module V1
      class ParticipationPolicy < BasePolicy
        def index?
          Collab::ParticipationPolicy.new(collaborator, record).index?
        end

        def show?
          Collab::ParticipationPolicy.new(collaborator, record).show?
        end

        def create?
          Collab::Participations::CreateFormPolicy.new(collaborator, record).create?
        end

        def update?
          Collab::ParticipationPolicy.new(collaborator, record).update?
        end

        def permitted_attributes
          [
            :type,
            attributes: %i[ended_at]
          ]
        end

        def permitted_includes
          %w[cohort]
        end

        class Scope < Scope
          def resolve
            Collab::ParticipationPolicy::Scope.new(collaborator, scope).resolve
          end
        end
      end
    end
  end
end
