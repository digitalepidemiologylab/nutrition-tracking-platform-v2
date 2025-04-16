# frozen_string_literal: true

class PushNotification < ApplicationRecord
  has_paper_trail on: %i[destroy]

  belongs_to :push_token, inverse_of: :push_notifications
  belongs_to :comment, inverse_of: :push_notifications

  validates :message, presence: true

  after_create_commit :push

  def mark_as_sent!
    return if sent?

    update!(sent_at: Time.current)
  end

  def sent?
    sent_at.present?
  end

  private def push
    if push_token.platform_ios?
      PushNotifications::PushToApnsJob.perform_later(push_notification: self)
    elsif push_token.platform_android?
      PushNotifications::PushToFcmJob.perform_later(push_notification: self)
    end
  end
end
