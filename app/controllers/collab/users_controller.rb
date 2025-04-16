# frozen_string_literal: true

module Collab
  class UsersController < BaseController
    before_action :set_breadcrumbs, only: %i[index show]
    before_action :set_user, only: %i[show destroy]
    before_action :set_associated_records, only: :show

    def index
      authorize(User)
      @users = UsersQuery
        .new(initial_scope: policy_scope(User), policy: policy([:collab, User]))
        .query(
          params: params,
          includes: [participations: :cohort]
        )
      @pagy, @users = pagy(@users)
    end

    def show
      @breadcrumbs << {text: @user.email}
      render layout: "collab/user"
    end

    def destroy
      service = ::Users::DestroyService.new(user: @user)
      if service.call
        redirect_to collab_users_path, notice: t(".success")
      else
        set_breadcrumbs
        @breadcrumbs << {text: @user.email}
        set_associated_records
        flash.now[:alert] = [t(".failure"), service.errors&.full_messages&.to_sentence].compact.join(": ")
        render :show, status: :unprocessable_entity
      end
    end

    private def set_user
      @user = User.find(params[:id])
      authorize(@user)
    end

    private def set_associated_records
      @anonymize_service = ::Users::AnonymizeService.new(user: @user)
      @participations = policy_scope(@user.participations)
        .order(created_at: :desc)
      @pagy_participations, @participations = pagy(@participations, page_param: :participations_page)
      @intakes = policy_scope(@user.intakes)
        .includes(annotation: {dish: [{dish_image: {data_attachment: :blob}}, {user: {participations: :cohort}}]})
        .order(created_at: :desc)
      @pagy_intakes, @intakes = pagy(@intakes, page_param: :intakes_page)
    end

    private def set_breadcrumbs
      @breadcrumbs = [{text: t("layouts.collab.users"), url: collab_users_path}]
    end
  end
end
