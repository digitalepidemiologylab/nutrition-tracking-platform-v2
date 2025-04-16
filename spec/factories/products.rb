# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    barcode { build(:barcode).code }
    unit factory: :unit, strategy: :create

    trait :with_name do
      I18n.available_locales.each do |locale|
        send("name_#{locale}") { [Faker::Food.ingredient, Faker::Food.spice].join(" ") }
      end
    end

    trait :with_unit do
      unit factory: :unit, strategy: :create
    end

    trait :with_portion_quantity do
      portion_quantity { Faker::Number.number(digits: 2) }
    end

    trait :with_product_images do
      product_images { build_list(:product_image, 2) }
    end

    trait :with_product_nutrients do
      product_nutrients { build_list(:product_nutrient, 2) }
    end
  end
end
