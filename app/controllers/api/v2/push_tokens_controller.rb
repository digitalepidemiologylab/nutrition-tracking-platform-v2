# frozen_string_literal: true

module Api
  module V2
    class PushTokensController < BaseController
      def create
        push_token_form = ::Users::PushTokenForm.new(
          user: current_api_v2_user,
          params: permitted_attributes(current_api_v2_user.push_tokens.new)
        )
        authorize(push_token_form.push_token)

        if push_token_form.save
          render jsonapi: push_token_form.push_token, status: :ok
        else
          render jsonapi_errors: push_token_form.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
