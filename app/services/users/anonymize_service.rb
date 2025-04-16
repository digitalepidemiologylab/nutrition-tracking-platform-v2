# frozen_string_literal: true

module Users
  class AnonymizeService < BaseActiveModelService
    attr_reader :user

    def initialize(user:)
      @user = user
    end

    def call(raise_exception: false)
      @user.password = SecureRandom.uuid
      @user.tokens = {}

      unless @user.anonymous?
        @user.anonymous = true
        @user.email = "#{@user.id}@#{User::ANONYMOUS_DOMAIN}"
      end
      @user.save!
    rescue => e
      errors.add(:base, e.message)
      raise e if raise_exception
      false
    end
  end
end
