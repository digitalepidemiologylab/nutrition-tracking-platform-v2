# frozen_string_literal: true

module Seeds
  class FoodsImportService
    def initialize
      @s3_seed_import_service = Seeds::S3SeedImportService.new(
        collection_name: "foods",
        item_hash_lambda: ->(row) {
          food_list = FoodList.find_or_create_by!(name: "Food list #{row["list_country_id"]} v1.0", country_id: row["list_country_id"])
          {
            id_v1: row["id"],
            food_list_id: food_list.id,
            unit_id: row["unit_id"],
            annotatable: row["annotatable"],
            segmentable: row["segmentable"],
            fa_ps_ratio: row["fa_ps_ratio"],
            kcal_min: row["energy_kcal_min"],
            kcal_max: row["energy_kcal_max"]
          }
        },
        items_import_lambda: ->(items) {
          Food.upsert_all(items, returning: %w[id id_v1])
        },
        item_id_finder_lambda: ->(result, row) { result["id_v1"].to_s == row["id"] },
        translation_hash_lambda: ->(item_id, row, locale) {
          name = row["display_name_#{locale}"].presence || row["name_#{locale}"].presence
          return nil if name.blank?

          {
            name: name,
            locale: locale,
            food_id: item_id
          }
        },
        translations_import_lambda: ->(translations) { Food::Translation.upsert_all(translations) }
      )
    end

    def call(limit: nil)
      @s3_seed_import_service.call(limit: limit)
    end
  end
end
