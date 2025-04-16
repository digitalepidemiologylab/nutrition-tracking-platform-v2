# frozen_string_literal: true

module Collab
  class FoodListsController < BaseController
    before_action :set_food_list, only: %i[show edit update destroy]
    before_action :set_breadcrumbs

    def index
      authorize(FoodList)
      @food_lists = FoodListsQuery
        .new(initial_scope: policy_scope(FoodList), policy: policy([:collab, FoodList]))
        .query(
          params: params,
          includes: [country: :translations]
        )

      @pagy, @food_lists = pagy(@food_lists)
    end

    def show
      @breadcrumbs << {text: @food_list.name}
      @cohorts = @food_list.cohorts
      foods = FoodsQuery
        .new(initial_scope: policy_scope(@food_list.foods), policy: policy([:collab, Food]))
        .query(
          params: params,
          includes: [:unit, :translations, :food_nutrients, :food_list, food_sets: :translations]
        )
      @pagy, @foods = pagy(foods)
    end

    def edit
      set_countries
      @breadcrumbs << {text: t(".title")}
    end

    def update
      if @food_list.update(permitted_attributes(@food_list))
        redirect_to collab_food_list_path(@food_list), notice: t(".success")
      else
        set_countries
        @breadcrumbs << {text: t("collab.food_lists.edit.title")}
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @food_list.destroy
        redirect_to collab_food_lists_path, notice: t(".success"), status: :see_other
      else
        @breadcrumbs << {text: @food_list.name}
        redirect_to collab_food_list_path(@food_list), alert: t(".failure")
      end
    end

    private def set_food_list
      @food_list = FoodList.find(params[:id])
      authorize(@food_list)
    end

    private def set_countries
      @countries = Country.i18n.includes(:translations).order(:name)
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("layouts.collab.food_lists"), url: collab_food_lists_path}]
    end
  end
end
