# frozen_string_literal: true

module Collab
  class FoodSetsController < BaseController
    include HasAnnotations

    before_action :set_food_set, only: %i[show edit update destroy]
    before_action :set_breadcrumbs

    def index
      authorize(FoodSet)
      @food_sets = FoodSetsQuery
        .new(initial_scope: policy_scope(FoodSet), policy: policy([:collab, FoodSet]))
        .query(
          params: params,
          includes: %i[translations]
        )

      @pagy, @food_sets = pagy(@food_sets)
      respond_to do |format|
        format.html
        format.json {
          render jsonapi: @food_sets, meta: pagy_metadata(@pagy), status: :ok
        }
      end
    end

    def show
      @breadcrumbs << {text: @food_set.cname}
      foods = FoodsQuery
        .new(initial_scope: policy_scope(@food_set.foods), policy: policy([:collab, Food]))
        .query(
          params: params,
          includes: [:unit, :translations, :food_nutrients, :food_list, food_sets: :translations]
        )
      @pagy, @foods = pagy(foods)
      @image_gallery_annotations = ::Annotations::FoodSetImagesGalleryQuery
        .new(food_set: @food_set, initial_scope: policy_scope(Annotation))
        .query
      list_annotations
    end

    def new
      @food_set = FoodSet.new
      authorize(@food_set)
      @breadcrumbs << {text: t(".title")}
    end

    def edit
      @breadcrumbs << {text: t(".title")}
    end

    def create
      @food_set = FoodSet.new
      @food_set.assign_attributes(permitted_attributes(@food_set))
      authorize(@food_set)

      if @food_set.save
        redirect_to collab_food_set_path(@food_set), notice: t(".success")
      else
        @breadcrumbs << {text: t("collab.food_sets.new.title")}
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @food_set.update(permitted_attributes(@food_set))
        redirect_to collab_food_set_path(@food_set), notice: t(".success")
      else
        @breadcrumbs << {text: t("collab.food_sets.edit.title")}
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @food_set.destroy
        redirect_to collab_food_sets_path, notice: t(".success"), status: :see_other
      else
        @breadcrumbs << {text: @food_set.cname}
        redirect_to collab_food_set_path(@food_set), alert: t(".failure")
      end
    end

    private def set_food_set
      @food_set = FoodSet.find(params[:id])
      authorize(@food_set)
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("layouts.collab.food_sets"), url: collab_food_sets_path}]
    end

    private def list_annotations
      initial_scope = policy_scope(Annotation)
        .joins(:annotation_items)
        .merge(AnnotationItem.where(food: @foods))
      set_annotations(initial_scope: initial_scope)
    end
  end
end
