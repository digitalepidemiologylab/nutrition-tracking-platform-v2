# frozen_string_literal: true

module Api
  module V2
    class DishFormsController < BaseController
      include ActiveStorage::SetCurrent

      def create
        dish_form = DishForm.new(user: current_api_v2_user)
        authorize(dish_form)
        if dish_form.save(params: permitted_attributes(dish_form))
          render jsonapi: dish_form, include: permitted_include_directive(dish_form, params[:include]), status: :ok
        else
          render jsonapi_errors: dish_form.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
