# frozen_string_literal: true

FactoryBot.define do
  factory :segmentation_client do
    name { "#{Faker::Company.name} #{Faker::Device.version}" }
    ml_model { |sc| "#{sc.name} (#{Faker::Number.number(digits: 6)})" }

    trait :with_cohort do
      cohorts { build_list(:cohort, 1) }
    end
  end
end
