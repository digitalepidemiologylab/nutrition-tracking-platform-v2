# frozen_string_literal: true

module Collab
  class CohortsController < BaseController
    before_action :set_cohort, only: %i[show edit update]
    before_action :set_food_lists, only: %i[new edit]
    before_action :set_segmentation_clients, only: %i[new edit]
    before_action :set_breadcrumbs

    def index
      authorize(Cohort)
      @cohorts = policy_scope(Cohort).order(created_at: :desc)
    end

    def show
      @breadcrumbs << {text: @cohort.name}
      @food_lists = policy_scope(@cohort.food_lists).order(Arel.sql("lower(unaccent(name))"))
      @collaborations = policy_scope(Collaboration).where(cohort: @cohort)
    end

    def new
      @cohort = Cohort.new
      authorize(@cohort)
      @breadcrumbs << {text: t(".title")}
    end

    def edit
      @breadcrumbs << {text: t(".title")}
    end

    def create
      @cohort = Cohort.new
      @cohort.assign_attributes(permitted_attributes(@cohort))
      authorize(@cohort)

      if @cohort.save
        redirect_to collab_cohort_path(@cohort), notice: t(".success")
      else
        @breadcrumbs << {text: t("collab.cohorts.new.title")}
        set_food_lists
        set_segmentation_clients
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @cohort.update(permitted_attributes(@cohort))
        redirect_to collab_cohort_path(@cohort), notice: t(".success")
      else
        @breadcrumbs << {text: t("collab.cohorts.edit.title")}
        set_food_lists
        set_segmentation_clients
        render :edit, status: :unprocessable_entity
      end
    end

    private def set_cohort
      @cohort = Cohort.find(params[:id])
      authorize(@cohort)
    end

    private def set_food_lists
      @food_lists = policy_scope(FoodList).order(Arel.sql("lower(unaccent(name))"))
    end

    private def set_segmentation_clients
      @segmentation_clients = policy_scope(SegmentationClient).order(:name)
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("layouts.collab.cohorts"), url: collab_cohorts_path}]
    end
  end
end
