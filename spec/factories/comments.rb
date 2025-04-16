# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    message { Faker::Lorem.question }
    annotation factory: %i[annotation annotatable]
    user
    collaborator { nil }

    trait :from_collaborator do
      user { nil }
      collaborator
    end
  end
end
