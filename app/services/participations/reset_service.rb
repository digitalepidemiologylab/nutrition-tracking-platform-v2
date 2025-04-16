# frozen_string_literal: true

module Participations
  class ResetService < BaseActiveModelService
    validate :validate_participation, :validate_user

    def initialize(participation:)
      @participation = participation
      @user = participation.user
    end

    def call
      @participation.with_lock do
        @participation.reload

        @participation.associated_at = nil
        @user.tokens = nil
        raise ActiveModel::ValidationError.new(self) if invalid?

        ActiveRecord::Base.transaction do
          @participation.save!
          @user.save!
        end
      end
    end

    private def validate_participation
      promote_errors(@participation) if @participation.invalid?
    end

    private def validate_user
      promote_errors(@user) if @user.invalid?
    end
  end
end
