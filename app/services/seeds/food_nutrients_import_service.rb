# frozen_string_literal: true

module Seeds
  class FoodNutrientsImportService
    def initialize
      food_ids = Food.select(:id, :id_v1).to_h { |food| [food.id_v1, food.id] }
      @s3_seed_import_service = Seeds::S3SeedImportService.new(
        collection_name: "food_nutrients",
        item_hash_lambda: ->(row) {
          {
            food_id: food_ids[row["food_id"].to_i],
            nutrient_id: Seeds::NutrientsImportService.clean_cname(row["nutrient_cname"]),
            per_hundred: row["per_hundred"]
          }
        },
        items_import_lambda: ->(items) { FoodNutrient.upsert_all(items) }
      )
    end

    def call
      @s3_seed_import_service.call
    end
  end
end
