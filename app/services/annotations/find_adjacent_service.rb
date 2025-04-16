# frozen_string_literal: true

module Annotations
  class FindAdjacentService
    def initialize(annotation:, collaborator:)
      @annotation = annotation
      @collaborator = collaborator
    end

    def call
      last_intake = @annotation.last_intake
      annotations = Collab::AnnotationPolicy::Scope.new(@collaborator, Annotation).resolve
        .joins(:intakes, :participation)
        .includes(:last_intake, :annotation_items, dish: :dish_image)
        .select("annotations.*, MAX(intakes.consumed_at) AS max_consumed_at")
        .group("annotations.id")
        .where(participation: @annotation.participation)
        .where.not(id: @annotation.id)
      adjacent_annotations = {}
      adjacent_annotations[:previous] = annotations
        .having("MAX(intakes.consumed_at) <= ?", last_intake.consumed_at)
        .order("max_consumed_at DESC, created_at DESC")
        .limit(3)
        .reverse
      adjacent_annotations[:next] = annotations
        .having("MAX(intakes.consumed_at) >= ?", last_intake.consumed_at)
        .order("max_consumed_at ASC, created_at ASC")
        .limit(3)
        .to_a
      adjacent_annotations
    end
  end
end
