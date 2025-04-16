# frozen_string_literal: true

module PushNotifications
  class PushToApnsJob < ApplicationJob
    queue_as :push_notifications

    APNOTIC_POOL = Apnotic::ConnectionPool.new(
      {
        auth_method: :token,
        cert_path: StringIO.new(ENV.fetch("APNS_P8_KEY")),
        key_id: ENV.fetch("APNS_KEY_ID"),
        team_id: ENV.fetch("APNS_TEAM_ID"),
        url: Apnotic::APPLE_PRODUCTION_SERVER_URL
      }, size: 5
    ) do |connection|
      connection.on(:error) do |exception|
        Sentry.capture_exception(exception)
        Rails.logger.error("Apnotic::ConnectionPool: Exception has been raised: #{exception}")
      end
    end

    def perform(push_notification:)
      return if push_notification.sent?

      APNOTIC_POOL.with do |connection|
        response = connection.push(appnotic_notification(push_notification))
        push_notification.mark_as_sent!

        unless response
          push_notification.update!(error_message: "Timeout sending a push notification")
          break
        end

        push_notification.update!(response_status: response.status, response_body: response.body)

        if unavailable_device?(response)
          push_notification.push_token.deactivate!
        end
      end
    end

    private def appnotic_notification(push_notification)
      apnotic_notification = Apnotic::Notification.new(push_notification.push_token.token)
      apnotic_notification.topic = ENV.fetch("APNS_BUNDLE_ID")
      apnotic_notification.alert = push_notification.message
      apnotic_notification.sound = "default"
      apnotic_notification.badge = push_notification.badge
      apnotic_notification.custom_payload = {data: push_notification.data}
      apnotic_notification
    end

    private def unavailable_device?(response)
      response.status == "410" || (response.status == "400" && response.body["reason"] == "BadDeviceToken")
    end
  end
end
