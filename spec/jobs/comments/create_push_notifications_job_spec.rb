# frozen_string_literal: true

require "rails_helper"
RSpec.describe(Comments::CreatePushNotificationsJob) do
  let!(:user) { create(:user) }
  let!(:dish) { create(:dish, user: user) }
  let!(:annotation) { create(:annotation, dish: dish) }
  let!(:comment) { create(:comment, annotation: annotation) }
  let!(:push_token) { create(:push_token, user: user, locale: "fr") }
  let!(:push_token_deactivated) { create(:push_token, :deactivated, user: user, locale: "fr") }
  let(:job) { described_class.new }

  before do
    badge_count_service = instance_double(Users::BadgeCountService)
    allow(badge_count_service).to receive(:call).with(no_args).and_return(4)
    allow(Users::BadgeCountService).to receive(:new).and_return(badge_count_service)
  end

  it do
    expect { job.perform(comment: comment) }.to change(PushNotification, :count).by(1)
    expect(comment.push_notifications.last.badge).to eq(4)
    expect(comment.push_notifications.last.data).to eq(
      "annotation_focus" => "comments",
      "annotation_id" => annotation.id,
      "event" => "annotation_requires_attention"
    )
    expect(Users::BadgeCountService).to have_received(:new).with(user: user)
    expect(comment.push_notifications.last.message).to eq("Un plat nécessite votre attention ✏️")
  end
end
