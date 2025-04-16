# frozen_string_literal: true

module Participations
  class ParticipateService < BaseActiveModelService
    attr_reader :participation, :user

    validate :validate_participation

    def initialize(participation:, user:)
      @participation = participation
      @user = user
    end

    def call
      # Let's use pessimistic locking to prevent simultaneous change to the participation
      # (ie during a race condition) leading to unexpect behaviour.
      participation.with_lock do
        participation.reload
        raise ActiveModel::ValidationError.new(self) if participation_not_available_for_user?

        participation.user = user
        raise ActiveModel::ValidationError.new(self) if invalid?

        participation.save!
      end
    end

    private def validate_participation
      promote_errors(participation) if participation.invalid?
    end

    private def participation_not_available_for_user?
      return false if Api::V2::Participations::ParticipatePolicy.new(user, participation).create?

      errors.add(:key, I18n.t("errors.messages.exclusion"))
    end
  end
end
