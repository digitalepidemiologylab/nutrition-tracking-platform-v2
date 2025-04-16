# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8, mix_case: true, special_characters: true) }
    anonymous { false }

    trait "with_tokens" do
      tokens {
        {
          a_token: {
            token: Faker::Internet.device_token,
            expiry: 2.days.from_now.to_i
          }
        }
      }
    end

    trait :anonymous do
      id { Faker::Internet.uuid }
      anonymous { true }
      email { "#{id}@#{User::ANONYMOUS_DOMAIN}" }
    end

    trait :with_participation do
      participations { build_list(:participation, 1, started_at: 1.minute.ago) }
    end
  end
end
