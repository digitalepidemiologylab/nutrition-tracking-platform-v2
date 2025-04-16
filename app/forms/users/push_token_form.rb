# frozen_string_literal: true

module Users
  class PushTokenForm < BaseActiveModelService
    attr_reader :push_token

    validate :validate_push_token

    def initialize(user:, params:)
      @user = user
      @params = params
      @push_token = set_push_token
    end

    def save
      return false if invalid?

      push_token.save!
    end

    private def set_push_token
      token = @params.dig(:attributes, :token)
      existing_push_token = PushToken.find_by(token: token)

      if push_token_already_set?(existing_push_token: existing_push_token)
        existing_push_token
      else
        existing_push_token&.deactivate!
        build_push_token
      end
    end

    private def push_token_already_set?(existing_push_token:)
      attributes = @params[:attributes]
      token = attributes[:token]
      platform = attributes[:platform]
      locale = attributes[:locale]

      existing_push_token &&
        existing_push_token.user == @user &&
        existing_push_token.token == token &&
        existing_push_token.platform == platform &&
        existing_push_token.locale.to_s == locale.to_s
    end

    private def build_push_token
      attributes = @params[:attributes].merge(user: @user)
      attributes[:id] = @params[:id] if @params[:id].present?
      PushToken.new(attributes)
    end

    private def validate_push_token
      promote_errors(push_token) if push_token.invalid?
    end
  end
end
