# frozen_string_literal: true

module Collab
  class AnnotationsController < BaseController
    include HasAnnotations

    before_action :set_annotation, only: :show
    before_action :set_breadcrumbs

    def index
      authorize(Annotation)
      set_annotations(initial_scope: policy_scope(Annotation))
    end

    def show
      @dish = @annotation.dish
      @breadcrumbs << {text: t(".title")}
      set_associated_items
    end

    private def set_annotation
      @annotation = Annotation.find(params[:id])
      authorize(@annotation)
    end

    private def set_associated_items
      @annotation_items = @annotation.annotation_items
        .includes(:present_unit, :consumed_unit, :polygon_set, food: [:translations, food_nutrients: :nutrient])
        .order(position: :desc)
      # allow to display errors on each annotation_item
      @annotation_items.each(&:validate)
      @units = Unit.g_and_ml
      @comment = @annotation.comments.new
      intakes_query = policy_scope(@annotation.intakes)
        .includes(annotation: {dish: [{dish_image: {data_attachment: :blob}}, {user: {participations: :cohort}}]})
        .order(created_at: :desc)
      @pagy_intakes, @intakes = pagy(intakes_query, page_param: :intakes_page)
      @adjacent_annotations = ::Annotations::FindAdjacentService.new(annotation: @annotation, collaborator: current_collaborator).call
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("layouts.collab.pending_annotations"), url: collab_annotations_path}]
    end
  end
end
