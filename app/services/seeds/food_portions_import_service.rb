# frozen_string_literal: true

module Seeds
  class FoodPortionsImportService
    def initialize
      @s3_seed_import_service = Seeds::S3SeedImportService.new(
        collection_name: "food_portions",
        item_hash_lambda: ->(row) {
          return nil if row["default"] != "true"

          {
            id_v1: row["food_id"],
            unit_id: row["unit_id"],
            portion_quantity: row["quantity"],
            # Somehow we need to pass a food_list_id here even if it's not used
            food_list_id: FoodList.first.id
          }
        },
        items_import_lambda: ->(items) {
          Food.upsert_all(items, unique_by: :id_v1, update_only: %i[unit_id portion_quantity])
        }
      )
    end

    def call
      @s3_seed_import_service.call
    end
  end
end
