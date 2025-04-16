# frozen_string_literal: true

require "rails_helper"

RSpec.describe(PushNotification) do
  describe "Associations" do
    let(:push_notification) { build(:push_notification) }

    it do
      expect(push_notification).to belong_to(:push_token).inverse_of(:push_notifications)
      expect(push_notification).to belong_to(:comment).inverse_of(:push_notifications)
    end
  end

  describe "Validations" do
    let(:push_notification) { build(:push_notification) }

    it { expect(push_notification).to be_valid }
    it { expect(push_notification).to validate_presence_of(:message) }
  end

  describe "#mark_as_sent!" do
    let(:push_notification) { create(:push_notification) }

    it do
      expect { push_notification.mark_as_sent! }
        .to change(push_notification, :sent_at).from(nil)
    end
  end

  describe "Callbacks" do
    describe "after_create_commit" do
      describe "push" do
        let(:push_notification) { build(:push_notification, push_token: push_token) }

        context "when push_token platform is ios" do
          let(:push_token) { create(:push_token, :ios) }

          it do
            expect { push_notification.save }
              .to have_enqueued_job(PushNotifications::PushToApnsJob).with(push_notification: push_notification)
          end
        end

        context "when push_token platform is android" do
          let(:push_token) { create(:push_token, :android) }

          it do
            expect { push_notification.save }
              .to have_enqueued_job(PushNotifications::PushToFcmJob).with(push_notification: push_notification)
          end
        end
      end
    end
  end

  describe "#sent?" do
    let(:push_notification) { create(:push_notification, sent_at: sent_at) }

    context "when sent_at present" do
      let(:sent_at) { Time.current }

      it { expect(push_notification).to be_sent }
    end

    context "when sent_at nil" do
      let(:sent_at) { nil }

      it { expect(push_notification).not_to be_sent }
    end
  end
end
