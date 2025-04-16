# frozen_string_literal: true

FactoryBot.define do
  factory :food do
    unit factory: :unit, strategy: :create
    food_list
    I18n.available_locales.each do |locale|
      Mobility.with_locale(locale) do
        send("name_#{locale}") {
          loop do
            name_loc = "#{Faker::Adjective.positive} #{Faker::Food.dish}".camelcase
            break name_loc if Food.i18n.find_by(name: name_loc).blank?
          end
        }
      end
    end

    trait :editable do
      food_list factory: %i[food_list editable]
    end

    trait :with_food_set do
      food_food_sets { build_list(:food_food_set, 1) }
    end
  end
end
