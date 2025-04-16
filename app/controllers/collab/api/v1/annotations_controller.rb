# frozen_string_literal: true

module Collab
  module Api
    module V1
      class AnnotationsController < BaseController
        DEFAULT_ITEMS = 10
        MAX_ITEMS = 20

        before_action :set_participation, only: :index
        before_action :set_items, only: :index

        def index
          authorize(Annotation)
          include_directive = permitted_include_directive(Annotation, params[:include])
          anntotations = policy_scope(@participation.annotations).includes(include_directive)
          pagy, anntotations = pagy(anntotations, items: @items)
          render jsonapi: anntotations, include: include_directive, meta: pagy_metadata(pagy), status: :ok
        end

        private def set_participation
          @participation = Participation.find(params[:participation_id])
        end

        private def set_items
          @items = params[:items]&.to_i || DEFAULT_ITEMS
          @items = MAX_ITEMS if @items > MAX_ITEMS
        end
      end
    end
  end
end
