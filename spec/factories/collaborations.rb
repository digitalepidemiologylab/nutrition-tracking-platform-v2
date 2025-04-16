# frozen_string_literal: true

FactoryBot.define do
  factory :collaboration do
    cohort
    collaborator
    traits_for_enum(:role)

    trait :deactivated do
      deactivated_at { Time.current }
    end
  end
end
