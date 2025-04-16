# frozen_string_literal: true

module Seeds
  class NutrientsImportService
    def initialize
      @s3_seed_import_service = Seeds::S3SeedImportService.new(
        collection_name: "nutrients",
        item_hash_lambda: ->(row) { {id: self.class.clean_cname(row["cname"]), unit_id: row["unit_id"]} },
        items_import_lambda: ->(items) { Nutrient.upsert_all(items) },
        item_id_finder_lambda: ->(result, row) { result["id"].to_s == self.class.clean_cname(row["cname"]) },
        translation_hash_lambda: ->(item_id, row, locale) {
          name = row["name_#{locale}"]
          return nil if name.blank?

          {name: name, locale: locale, nutrient_id: item_id}
        },
        translations_import_lambda: ->(translations) { Nutrient::Translation.upsert_all(translations) }
      )
    end

    def call
      @s3_seed_import_service.call
      add_extra_nutrients
    end

    def self.clean_cname(cname)
      I18n.transliterate(cname).gsub(/[^a-z0-9_&]/, "_")
    end

    # Add nutrients that are not in MFR V1 but are in FoodRepo
    private def add_extra_nutrients
      extra_nutrients = [
        {
          id: "polyols",
          name_en: "Polyols",
          name_fr: "Polyols",
          name_de: "Polyole",
          unit_id: "g"
        },
        {
          id: "sugar_added",
          name_en: "Added sugars",
          name_fr: "Sucres ajoutés",
          name_de: "Zuckerzusatz",
          unit_id: "g"
        },
        {
          id: "silica",
          name_en: "Silica",
          name_fr: "Silice",
          name_de: "Silizium",
          unit_id: "mg"
        },
        {
          id: "sulfate",
          name_en: "Sulfate",
          name_fr: "Sulfate",
          name_de: "Sulfat",
          unit_id: "mg"
        },
        {
          id: "nitrate",
          name_en: "Nitrate",
          name_fr: "Nitrate",
          name_de: "Nitrat",
          unit_id: "mg"
        }
      ]
      extra_nutrients.each do |extra_nutrient|
        ::Nutrient.create!(extra_nutrient)
      end
    end
  end
end
