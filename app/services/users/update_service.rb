# frozen_string_literal: true

module Users
  class UpdateService < BaseActiveModelService
    attr_reader :user

    validate :validate_user

    def initialize(user:)
      @user = user
    end

    def call(params)
      new_attributes = params.fetch(:attributes, {})
      user.assign_attributes(new_attributes)
      user.anonymous = false if user.anonymous?
      return false if invalid?

      user.save!
    end

    private def validate_user
      promote_errors(user) if user.invalid?
    end
  end
end
