# frozen_string_literal: true

FactoryBot.define do
  factory :push_token do
    user
    token { Faker::Crypto.sha256 }
    platform { %w[android ios].sample }
    locale { I18n.available_locales.sample }

    trait :deactivated do
      deactivated_at { Time.current }
    end

    trait :android do
      platform { "android" }
    end

    trait :ios do
      platform { "ios" }
    end
  end
end
