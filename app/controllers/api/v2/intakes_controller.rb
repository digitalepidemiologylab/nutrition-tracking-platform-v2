# frozen_string_literal: true

module Api
  module V2
    class IntakesController < BaseController
      before_action :set_intake, only: %i[update destroy]
      skip_after_action :verify_policy_scoped, only: :index

      def index
        authorize(Intake)
        include_directive = permitted_include_directive(Intake, params[:include])
        initial_scope = policy_scope(Intake)
        intakes = IntakesQuery
          .new(
            initial_scope: initial_scope
          )
          .query(
            params: params,
            includes: include_directive
          )
        pagy, intakes = pagy(intakes)
        render jsonapi: intakes, include: include_directive, meta: metadata(pagy: pagy, params: params), status: :ok
      end

      def create
        dish = Dish.find(params[:dish_id])
        annotation = dish.annotations.find_by(participation: current_api_v2_user.current_participation)
        intake = Intake.new(annotation: annotation)
        intake.assign_attributes(permitted_attributes(intake).except(:type))
        authorize(intake)

        if intake.save
          render jsonapi: intake,
            include: permitted_include_directive(intake, params[:include]),
            status: :ok
        else
          render jsonapi_errors: intake.errors, status: :unprocessable_entity
        end
      end

      def update
        if @intake.update(permitted_attributes(@intake).except(:type))
          render jsonapi: @intake,
            include: permitted_include_directive(@intake, params[:include]),
            status: :ok
        else
          render jsonapi_errors: @intake.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @intake.destroy!
        head(:no_content)
      end

      private def set_intake
        @intake = Intake.find(params[:id])
        authorize(@intake)
      end

      private def metadata(pagy:, params:)
        pagy_metadata(pagy).merge(destroyed_intake_ids(params))
      end

      private def destroyed_intake_ids(params)
        destroyed_intakes = Intakes::RetrieveDestroyedService.new(params: params, user: current_api_v2_user).call
        {destroyed_intake_ids: destroyed_intakes.pluck(:item_id)}
      end
    end
  end
end
