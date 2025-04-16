# frozen_string_literal: true

module Collab
  module Users
    class AnonymizesController < BaseController
      def update
        @user = User.find(params[:user_id])
        service = ::Users::AnonymizeService.new(user: @user)
        authorize(service)
        if service.call
          flash[:notice] = t(".success")
        else
          flash[:alert] = [t(".failure"), service.errors&.full_messages&.to_sentence].compact.join(": ")
        end
        redirect_to collab_user_path(@user)
      end
    end
  end
end
