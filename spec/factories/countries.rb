# frozen_string_literal: true

FactoryBot.define do
  factory :country do
    id { %w[IT IN NL].sample }
    I18n.available_locales.each do |locale|
      send("name_#{locale}") { Faker::Address.country }
    end

    # Try to find and load existing instance before creating one
    to_create do |instance|
      country = Country.find_by(id: instance.id) ||
        Country.create!(
          id: instance.id,
          name_en: instance.name_en,
          name_fr: instance.name_fr,
          name_de: instance.name_de
        )
      instance.attributes = country.attributes
      instance.instance_variable_set(:@new_record, false)
    end

    trait :ch do
      id { "CH" }
      name_en { "Switzerland" }
      name_fr { "Suisse" }
      name_de { "Schweiz" }
    end

    trait :de do
      id { "DE" }
      name_en { "Germany" }
      name_fr { "Allemagne" }
      name_de { "Deutschland" }
    end

    trait :us do
      id { "US" }
      name_en { "USA" }
      name_fr { "USA" }
      name_de { "USA" }
    end
  end
end
