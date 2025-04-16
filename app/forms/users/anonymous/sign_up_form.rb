# frozen_string_literal: true

module Users
  module Anonymous
    class SignUpForm < BaseActiveModelService
      include ActiveModel::Model

      attr_accessor :participation, :user, :token

      validate :validate_participation, :validate_user

      def initialize(participation:)
        @participation = participation
        @user = build_anonymous_user
        @token = nil
      end

      def save!
        raise ActiveModel::ValidationError.new(self) if participation_blank?

        # Let's use pessimistic locking to prevent simultaneous change to the participation
        # (ie during a race condition) leading to unexpect behaviour.
        participation.with_lock do
          participation.reload
          raise ActiveModel::ValidationError.new(self) if participation_not_available?

          @token = user.create_token
          participation.user = user
          raise ActiveModel::ValidationError.new(self) if invalid?

          user.save!
          participation.save!
        end
      end

      private def build_anonymous_user
        anonymous_user_id = SecureRandom.uuid
        User.new(
          id: anonymous_user_id,
          anonymous: true,
          email: "#{anonymous_user_id}@#{User::ANONYMOUS_DOMAIN}",
          password: SecureRandom.uuid
        )
      end

      private def participation_blank?
        return false if participation.present? && participation.persisted?

        errors.add(:key, I18n.t("errors.messages.doesnt_exist"))
      end

      private def participation_not_available?
        return false if participation_available?

        errors.add(:participation, I18n.t("errors.messages.exclusion"))
      end

      private def validate_participation
        promote_errors(participation) if participation.invalid?
      end

      private def validate_user
        promote_errors(user) if user.invalid?
      end

      private def participation_available?
        participation.user.blank? && participation.associated_at.blank?
      end
    end
  end
end
