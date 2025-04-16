# frozen_string_literal: true

module Comments
  class CreatePushNotificationsJob < ApplicationJob
    queue_as :default

    def perform(comment:)
      dish_user = comment.dish.user
      push_tokens = dish_user.push_tokens.active
      badge_count = ::Users::BadgeCountService.new(user: dish_user).call

      push_tokens.each do |push_token|
        comment.push_notifications.create!(
          push_token: push_token,
          badge: badge_count,
          message: I18n.t("push_notifications.dish_requires_attention", locale: push_token.locale),
          data: {
            event: :annotation_requires_attention,
            annotation_id: comment.annotation_id,
            annotation_focus: :comments
          }
        )
      end
    end
  end
end
