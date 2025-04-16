# frozen_string_literal: true

FactoryBot.define do
  factory :food_nutrient do
    food
    nutrient
    per_hundred { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end
