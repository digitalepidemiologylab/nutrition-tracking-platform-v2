# frozen_string_literal: true

FactoryBot.define do
  factory :collaborator do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8, mix_case: true, special_characters: true) }
    session_token { SecureRandom.hex }
    admin { false }
    webauthn_credentials { build_list(:webauthn_credential, 1, collaborator: nil) }

    trait :admin do
      admin { true }
    end

    trait :no_webauthn_credentials do
      webauthn_credentials { [] }
    end
  end
end
