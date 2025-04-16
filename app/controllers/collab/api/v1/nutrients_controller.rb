# frozen_string_literal: true

module Collab
  module Api
    module V1
      class NutrientsController < BaseController
        DEFAULT_ITEMS = 250
        MAX_ITEMS = 250

        before_action :set_items, only: :index

        def index
          authorize(Nutrient)
          nutrients = policy_scope(Nutrient)
          pagy, nutrients = pagy(nutrients, items: @items)
          render jsonapi: nutrients, meta: pagy_metadata(pagy), status: :ok
        end

        private def set_items
          @items = params[:items]&.to_i || DEFAULT_ITEMS
          @items = MAX_ITEMS if @items > MAX_ITEMS
        end
      end
    end
  end
end
