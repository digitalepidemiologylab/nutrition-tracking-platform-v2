# frozen_string_literal: true

FactoryBot.define do
  sequence(:id_v1) { |n| n }

  factory :food_set do
    id_v1 { generate(:id_v1) }
    I18n.available_locales.each do |locale|
      Mobility.with_locale(locale) do
        send("name_#{locale}") {
          loop do
            name_loc = "#{Faker::Adjective.positive} #{Faker::Adjective.positive} #{Faker::Food.dish}".camelcase
            break name_loc if Food.i18n.find_by(name: name_loc).blank?
          end
        }
      end
    end
    cname do |food_set|
      Mobility.with_locale(:en) do
        food_set.name&.parameterize&.underscore&.downcase
      end
    end
  end
end
