# frozen_string_literal: true

module Collab
  class NoteFormPolicy < BasePolicy
    def show?
      collaborator.admin? || manager_or_annotator?(cohort: record.notable.cohorts)
    end

    def edit?
      show?
    end

    def update?
      show?
    end

    def permitted_attributes
      %i[note]
    end
  end
end
