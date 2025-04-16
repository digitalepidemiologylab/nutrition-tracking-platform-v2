# frozen_string_literal: true

FactoryBot.define do
  factory :webauthn_credential do
    collaborator
    external_id { SecureRandom.base64(64) }
    public_key { SecureRandom.base64(64) }
    nickname { Faker::Company.buzzword }
    sign_count { Faker::Number.number(digits: 2) }
  end
end
