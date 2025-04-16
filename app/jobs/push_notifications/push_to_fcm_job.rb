# frozen_string_literal: true

module PushNotifications
  class PushToFcmJob < ApplicationJob
    queue_as :push_notifications

    def perform(push_notification:)
      return if push_notification.sent?

      fcm = FCM.new(ENV["FCM_SERVER_KEY"])
      response = fcm.send_notification([push_notification.push_token.token], payload(push_notification))

      push_notification.mark_as_sent!

      unless response
        push_notification.update!(error_message: "Timeout sending a push notification")
        return
      end

      error_code = error_code(response)

      push_notification.update!(
        response_status: response[:status_code],
        response_body: response[:body],
        error_message: error_code
      )

      return unless unavailable_device?(error_code)

      push_notification.push_token.deactivate!
    end

    private def payload(push_notification)
      data = {"message" => push_notification.message}
      {"data" => (push_notification.data&.merge(data) || data)}
    end

    private def unavailable_device?(error_code)
      return false if error_code.blank?

      %w[InvalidRegistration MissingRegistration NotRegistered].include?(error_code)
    end

    private def error_code(response)
      body = response[:body]
      return if body.blank?

      body_json = JSON.parse(body)
      body_json["results"]&.first&.dig("error")
    end
  end
end
