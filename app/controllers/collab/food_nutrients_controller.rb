# frozen_string_literal: true

module Collab
  class FoodNutrientsController < BaseController
    before_action :set_food, only: %i[new]

    def new
      @food_nutrient = @food.food_nutrients.new
      set_remaining_nutrients
    end

    private def set_food
      @food = if params[:food_id]
        Food.find(params[:food_id])
      else
        Food.new
      end
      authorize(@food, :edit?)
    end

    private def set_remaining_nutrients
      nutrient_ids = @food.food_nutrients.filter_map { |fn| fn.nutrient_id if fn.persisted? }
      @remaining_nutrients = Nutrient
        .select(:id, :name)
        .joins(:translations)
        .includes(:translations)
        .where.not(id: nutrient_ids)
        .order(Arel.sql("lower(unaccent(nutrient_translations.name))"))
    end
  end
end
