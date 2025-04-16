# frozen_string_literal: true

require "rails_helper"

RSpec.describe(PushNotifications::PushToApnsJob, :freeze_time) do
  let(:mock_http_response) { Struct.new(:status, :body) }
  let!(:user) { create(:user) }
  let!(:push_token_ios) { create(:push_token, :ios) }
  let!(:push_notification) { create(:push_notification, push_token: push_token_ios) }
  let(:job) { described_class.new }

  context "when push_notification is already sent" do
    before do
      allow_any_instance_of(PushNotification).to receive(:sent?).and_return(true)
    end

    it { expect(job.perform(push_notification: push_notification)).to be_nil }
  end

  context "when push is successful" do
    it do
      response = mock_http_response.new("200")
      allow_any_instance_of(Apnotic::Connection).to receive(:push).and_return(response)
      expect { job.perform(push_notification: push_notification) }
        .to change { push_notification.reload.sent_at }.from(nil).to(Time.current)
        .and(change(push_notification, :response_status).from(nil).to("200"))
        .and(not_change(push_notification, :response_body))
        .and(not_change(push_notification, :error_message))
        .and(not_change { push_notification.push_token.reload.token })
        .and(not_change { push_token_ios.reload.deactivated_at }.from(nil))
    end
  end

  context "when push returns nil" do
    it do
      allow_any_instance_of(Apnotic::Connection).to receive(:push).and_return(nil)
      expect { job.perform(push_notification: push_notification) }
        .to change { push_notification.reload.sent_at }.from(nil).to(Time.current)
        .and(change(push_notification, :error_message).from(nil).to("Timeout sending a push notification"))
        .and(not_change(push_notification, :response_status))
        .and(not_change(push_notification, :response_body))
        .and(not_change { push_notification.push_token.reload.token })
        .and(not_change { push_token_ios.reload.deactivated_at }.from(nil))
    end
  end

  context "when push is error nil" do
    context "when response_status is 410" do
      it do
        response = mock_http_response.new("410")
        allow_any_instance_of(Apnotic::Connection).to receive(:push).and_return(response)
        expect { job.perform(push_notification: push_notification) }
          .to change { push_notification.reload.sent_at }.from(nil).to(Time.current)
          .and(not_change(push_notification, :error_message))
          .and(change(push_notification, :response_status).from(nil).to("410"))
          .and(not_change(push_notification, :response_body))
          .and(not_change { push_token_ios.reload.platform }.from("ios"))
          .and(not_change { push_token_ios.reload.token })
          .and(change { push_token_ios.reload.deactivated_at }.from(nil))
      end
    end

    context "when response_status is 400 and reason is BadDeviceToken" do
      it do
        response = mock_http_response.new("400", {"reason" => "BadDeviceToken"})
        allow_any_instance_of(Apnotic::Connection).to receive(:push).and_return(response)
        expect { job.perform(push_notification: push_notification) }
          .to change { push_notification.reload.sent_at }.from(nil).to(Time.current)
          .and(not_change(push_notification, :error_message))
          .and(change(push_notification, :response_status).from(nil).to("400"))
          .and(change(push_notification, :response_body).from(nil).to("{\"reason\"=>\"BadDeviceToken\"}"))
          .and(not_change { push_token_ios.reload.platform }.from("ios"))
          .and(not_change { push_token_ios.reload.token })
          .and(change { push_token_ios.reload.deactivated_at }.from(nil))
      end
    end
  end
end
