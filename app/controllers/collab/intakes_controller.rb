# frozen_string_literal: true

module Collab
  class IntakesController < BaseController
    before_action :set_user, only: %i[index]
    before_action :set_breadcrumbs

    def index
      authorize(Intake)
      intakes_query = IntakesQuery
        .new(
          initial_scope: policy_scope(@user.intakes),
          policy: policy([:collab, Intake])
        )
        .query(
          params: params
        )
      @pagy_intakes, @intakes = pagy(intakes_query)
      render layout: "collab/user"
    end

    def set_user
      @user = User.find(params[:user_id])
      authorize(@user)
    end

    private def set_breadcrumbs
      @breadcrumbs = [
        {text: t("layouts.collab.users"), url: collab_users_path},
        {text: @user.email, url: collab_user_path(@user)}
      ]
    end
  end
end
