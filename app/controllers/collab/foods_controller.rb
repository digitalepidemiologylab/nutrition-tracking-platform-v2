# frozen_string_literal: true

module Collab
  class FoodsController < BaseController
    include HasAnnotations

    before_action :set_food, only: %i[show edit update destroy]
    before_action :set_food_lists, only: %i[new edit]
    before_action :set_food_nutrients, only: %i[show edit]
    before_action :set_remaining_nutrients, only: %i[edit]
    before_action :set_breadcrumbs

    def index
      authorize(Food)
      foods = FoodsQuery
        .new(initial_scope: policy_scope(Food), policy: policy([:collab, Food]))
        .query(
          params: params,
          includes: [:unit, :translations, :food_nutrients, :food_list, food_sets: :translations]
        )

      @pagy, @foods = pagy(foods)
      respond_to do |format|
        format.html
        format.json {
          render jsonapi: @foods, meta: pagy_metadata(@pagy), status: :ok
        }
      end
    end

    def show
      @breadcrumbs << {text: @food.name}
      @image_gallery_annotations = ::Annotations::FoodImagesGalleryQuery
        .new(food: @food, initial_scope: policy_scope(Annotation))
        .query
      list_annotations
    end

    def new
      @food = Food.new
      authorize(@food)
      @breadcrumbs << {text: t(".title")}
    end

    def edit
      @breadcrumbs << {text: t(".title")}
    end

    def create
      @food = Food.new
      @food.assign_attributes(permitted_attributes(@food))
      authorize(@food)

      if @food.save
        redirect_to collab_food_path(@food), notice: t(".success")
      else
        set_food_lists
        @food_nutrients = @food.food_nutrients
        set_remaining_nutrients
        @breadcrumbs << {text: t("collab.foods.new.title")}
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @food.update(permitted_attributes(@food))
        redirect_to collab_food_path(@food), notice: t(".success")
      else
        set_food_lists
        @food_nutrients = @food.food_nutrients
        set_remaining_nutrients
        @breadcrumbs << {text: t("collab.foods.edit.title")}
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @food.destroy
        redirect_to collab_foods_path, notice: t(".success"), status: :see_other
      else
        @breadcrumbs << {text: @food.name}
        redirect_to collab_food_path(@food), alert: t(".failure")
      end
    end

    private def set_food
      @food = Food.find(params[:id])
      authorize(@food)
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("layouts.collab.foods"), url: collab_foods_path}]
    end

    private def list_annotations
      initial_scope = policy_scope(Annotation)
        .joins(:annotation_items)
        .merge(AnnotationItem.where(food: @food))
      set_annotations(initial_scope: initial_scope)
    end

    private def set_food_lists
      @food_lists = policy_scope(FoodList).order(Arel.sql("lower(unaccent(name))"))
    end

    private def set_food_nutrients
      @food_nutrients = @food.food_nutrients.joins(nutrient: :translations).includes(nutrient: :translations).order(Arel.sql("lower(unaccent(nutrient_translations.name))"))
    end

    private def set_remaining_nutrients
      nutrient_ids = @food_nutrients.filter_map { |fn| fn.nutrient_id if fn.persisted? }
      @remaining_nutrients = Nutrient
        .includes(:translations)
        .where.not(id: nutrient_ids)
        .order("nutrient_translations.name")
    end
  end
end
