# frozen_string_literal: true

FactoryBot.define do
  factory :food_list do
    country
    name { [Faker::Lorem.word, Faker::Lorem.word, Faker::Lorem.word].join(" ") }
    editable { false }

    trait :editable do
      editable { true }
    end

    trait :with_foods do
      foods { build_list(:food, 2) }
    end
  end
end
