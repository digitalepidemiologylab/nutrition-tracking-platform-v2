# frozen_string_literal: true

module Seeds
  class FoodFoodSetsImportService
    def initialize
      food_ids = Food.select(:id, :id_v1).to_h { |food| [food.id_v1, food.id] }
      food_set_ids = FoodSet.select(:cname, :id).to_h { |food_set| [food_set.cname, food_set.id] }
      @s3_seed_import_service = Seeds::S3SeedImportService.new(
        collection_name: "food_food_sets",
        item_hash_lambda: ->(row) {
          {
            food_id: food_ids[row["food_id"].to_i],
            food_set_id: food_set_ids[row["food_set_cname"]]
          }
        },
        items_import_lambda: ->(items) { FoodFoodSet.upsert_all(items) }
      )
    end

    def call
      @s3_seed_import_service.call
    end
  end
end
