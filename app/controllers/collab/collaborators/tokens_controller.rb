# frozen_string_literal: true

module Collab
  module Collaborators
    class TokensController < BaseController
      before_action :set_collaborator

      def create
        devise_token = @collaborator.create_token

        if @collaborator.save
          @token = devise_token.token
          @client = devise_token.client
          flash.now[:notice] = t(".success")
        else
          flash.now[:alert] = @collaborator.errors.full_messages.to_sentence
        end
      end

      def destroy
        @client = params[:client]
        @collaborator.tokens.delete(@client)

        if @collaborator.save
          @client_destroyed = true
          flash.now[:notice] = t(".success")
        else
          flash.now[:alert] = @collaborator.errors.full_messages.to_sentence
        end
      end

      private def set_collaborator
        @collaborator = current_collaborator
        authorize(@collaborator, policy_class: Collab::Collaborators::TokenPolicy)
      end
    end
  end
end
