# frozen_string_literal: true

module Collab
  class CollaborationsController < BaseController
    before_action :set_collaboration, :set_breadcrumbs

    def edit
      @breadcrumbs << {text: t(".title")}
    end

    def update
      if @collaboration.update(permitted_attributes(@collaboration))
        redirect_to collab_cohort_path(@collaboration.cohort), notice: t(".success")
      else
        @breadcrumbs << {text: t("collab.collaborations.edit.title")}
        render :edit, status: :unprocessable_entity
      end
    end

    private def set_collaboration
      @collaboration = Collaboration.find(params[:id])
      authorize(@collaboration)
    end

    private def set_breadcrumbs
      @breadcrumbs = [
        {text: t("layouts.collab.cohorts"), url: collab_cohorts_path},
        {text: @collaboration.cohort.name, url: collab_cohort_path(@collaboration.cohort)}
      ]
    end
  end
end
