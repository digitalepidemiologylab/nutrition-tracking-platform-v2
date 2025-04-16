# frozen_string_literal: true

FactoryBot.define do
  factory :push_notification do
    push_token
    comment
    message { Faker::Lorem.sentence }
  end
end
