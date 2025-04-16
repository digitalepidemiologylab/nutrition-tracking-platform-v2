# frozen_string_literal: true

module Seeds
  class FoodSetsImportService
    def initialize
      @s3_seed_import_service = Seeds::S3SeedImportService.new(
        collection_name: "food_sets",
        item_hash_lambda: ->(row) {
          {
            id_v1: row["id"],
            cname: row["cname"]
          }
        },
        items_import_lambda: ->(items) { FoodSet.upsert_all(items, returning: %w[id cname]) },
        item_id_finder_lambda: ->(result, row) { result["cname"].to_s == row["cname"] },
        translation_hash_lambda: ->(item_id, row, locale) {
          name = row["name_#{locale}"]
          return nil if name.blank?

          {name: name, locale: locale, food_set_id: item_id}
        },
        translations_import_lambda: ->(translations) { FoodSet::Translation.upsert_all(translations) }
      )
    end

    def call
      @s3_seed_import_service.call
    end
  end
end
