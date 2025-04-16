# frozen_string_literal: true

module Collab
  class ParticipationsController < BaseController
    before_action :set_parent
    before_action :set_participations, only: %i[index]
    before_action :set_participation, only: %i[edit update destroy]
    before_action :set_breadcrumbs

    def index
      authorize(Participation)
      relation = policy_scope(@participations)
        .order(created_at: :desc)
      @pagy_participations, @participations = pagy(relation)
      if @user
        render "user_index", layout: "collab/user"
      else
        @participations_create_form = ::Participations::CreateForm.new(cohort: @cohort)
      end
    end

    def edit
      @breadcrumbs << {text: t(".title")}
    end

    def update
      if @participation.update(permitted_attributes(@participation))
        redirect_to collab_cohort_path(@cohort), notice: t(".success")
      else
        @breadcrumbs << {text: t("collab.participations.edit.title")}
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @participation.destroy
        redirect_to collab_cohort_path(@cohort), notice: t(".success")
      else
        flash.now[:error] = t(".failure")
        render status: :unprocessable_entity
      end
    end

    private def set_parent
      if params[:cohort_id]
        @parent = @cohort = Cohort.find(params[:cohort_id])
      elsif params[:user_id]
        @parent = @user = User.find(params[:user_id])
      end
      authorize(@parent, :show?)
    end

    private def set_participation
      @participation = @cohort.participations.find(params[:id])
      authorize(@participation)
    end

    def set_participations
      @participations = @parent.participations
    end

    private def set_breadcrumbs
      @breadcrumbs = if @user
        [
          {text: t("layouts.collab.users"), url: collab_users_path},
          {text: @user.email, url: collab_user_path(@user)}
        ]
      else
        [
          {text: t("layouts.collab.cohorts"), url: collab_cohorts_path},
          {text: @cohort.name, url: collab_cohort_path(@cohort)}
        ]
      end
    end
  end
end
