# frozen_string_literal: true

module Users
  module Anonymous
    class SignInForm < BaseActiveModelService
      attr_accessor :user, :token

      validate :validate_participation, :validate_user

      def initialize(participation:)
        @participation = participation
        @user = @participation&.user
        @token = nil
      end

      def save!
        raise ActiveModel::ValidationError.new(self) if participation_blank?

        # Let's use pessimistic locking to prevent simultaneous change to the participation
        # (ie during a race condition) leading to unexpect behaviour.
        @participation.with_lock do
          @participation.reload
          raise ActiveModel::ValidationError.new(self) if participation_not_available?

          @user = @participation.user
          @token = user.create_token
          @participation.set_associated_at
          raise ActiveModel::ValidationError.new(self) if invalid?

          user.save!
          @participation.save!
        end
      end

      private def participation_blank?
        return false if @participation.present? && @participation.persisted?

        errors.add(:key, I18n.t("errors.messages.doesnt_exist"))
      end

      private def participation_not_available?
        return false if participation_available?

        errors.add(:participation, I18n.t("errors.messages.exclusion"))
      end

      private def participation_available?
        @participation.user.present? && @participation.associated_at.blank?
      end

      private def validate_participation
        promote_errors(@participation) if @participation.invalid?
      end

      private def validate_user
        promote_errors(user) if user.invalid?
      end
    end
  end
end
