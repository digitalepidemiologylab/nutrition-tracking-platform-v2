# frozen_string_literal: true

FactoryBot.define do
  factory :nutrient do
    unit factory: :unit, strategy: :create
    I18n.available_locales.each do |locale|
      send("name_#{locale}") { [Faker::Food.ingredient, Faker::Food.spice, Faker::Food.ingredient].join(" ") }
    end
    id do |nutrient|
      Mobility.with_locale(:en) do
        nutrient.name&.parameterize&.underscore&.downcase
      end
    end
  end
end
