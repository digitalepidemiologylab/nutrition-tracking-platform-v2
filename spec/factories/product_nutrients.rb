# frozen_string_literal: true

FactoryBot.define do
  factory :product_nutrient do
    product
    nutrient
    per_hundred { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end
