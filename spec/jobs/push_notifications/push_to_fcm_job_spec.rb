# frozen_string_literal: true

require "rails_helper"
RSpec.describe(PushNotifications::PushToFcmJob, :freeze_time) do
  let!(:user) { create(:user) }
  let!(:push_token_android) { create(:push_token, :android) }
  let!(:push_notification) { create(:push_notification, push_token: push_token_android) }
  let(:job) { described_class.new }

  describe "#perform" do
    context "when push_notification is already sent" do
      before do
        allow_any_instance_of(PushNotification).to receive(:sent?).and_return(true)
      end

      it { expect(job.perform(push_notification: push_notification)).to be_nil }
    end

    context "when push is successful" do
      it do
        response = {status_code: 200}
        allow_any_instance_of(FCM).to receive(:send_notification).and_return(response)
        expect { job.perform(push_notification: push_notification) }
          .to change { push_notification.reload.sent_at }.from(nil).to(Time.current)
          .and(change(push_notification, :response_status).from(nil).to("200"))
          .and(not_change(push_notification, :response_body))
          .and(not_change(push_notification, :error_message))
          .and(not_change { push_token_android.reload.token })
      end
    end

    context "when push returns nil" do
      it do
        allow_any_instance_of(FCM).to receive(:send_notification).and_return(nil)
        expect { job.perform(push_notification: push_notification) }
          .to change { push_notification.reload.sent_at }.from(nil).to(Time.current)
          .and(change(push_notification, :error_message).from(nil).to("Timeout sending a push notification"))
          .and(not_change(push_notification, :response_status))
          .and(not_change(push_notification, :response_body))
          .and(not_change { push_token_android.reload.token })
      end
    end

    context "when error reason is InvalidRegistration" do
      it do
        response = {status_code: 200, body: {results: [{error: "InvalidRegistration"}]}.to_json}
        allow_any_instance_of(FCM).to receive(:send_notification).and_return(response)
        expect { job.perform(push_notification: push_notification) }
          .to change { push_notification.reload.sent_at }.from(nil).to(Time.current)
          .and(change(push_notification, :error_message))
          .and(change(push_notification, :response_status).from(nil).to("200"))
          .and(change(push_notification, :response_body).from(nil).to("{\"results\":[{\"error\":\"InvalidRegistration\"}]}"))
          .and(not_change { push_token_android.reload.token })
          .and(not_change { push_token_android.reload.platform }.from("android"))
      end
    end
  end

  describe "#payload" do
    context "without data" do
      it do
        expect(job.send(:payload, push_notification))
          .to eq({"data" => {"message" => push_notification.message}})
      end
    end

    context "with data" do
      before { push_notification.data = {"dish_id" => 123, "event" => "an_event"} }

      it do
        expect(job.send(:payload, push_notification))
          .to eq({"data" => {"message" => push_notification.message, "dish_id" => 123, "event" => "an_event"}})
      end
    end
  end
end
