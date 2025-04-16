# frozen_string_literal: true

module Foods
  class UpdateKcalMaxService
    def call(datetime: nil)
      foods = datetime.is_a?(Time) ? last_annotated_foods_since(datetime: datetime) : all_foods
      foods.find_each do |food|
        next if food.kcal_max == food.kcal_consumed_z_score

        food.update!(kcal_max: food.kcal_consumed_z_score)
      end
    end

    private def all_foods
      kcal = "annotation_items.consumed_kcal"
      Food
        .select(
          <<~SQL.squish
            foods.*,
            COUNT(*) AS kcal_consumed_count,
            CEIL(AVG(#{kcal}) + 4 * STDDEV(#{kcal})) AS kcal_consumed_z_score
          SQL
        )
        .joins(:annotation_items)
        .where.not(annotation_items: {consumed_kcal: nil})
        .group("foods.id")
        .having("COUNT(*) > 3")
    end

    private def last_annotated_foods_since(datetime:)
      last_annotated_foods = Food
        .select(:id)
        .joins(:annotation_items)
        .group("foods.id")
        .having("MAX(annotation_items.updated_at) >= ?", datetime)
      all_foods.where(id: last_annotated_foods)
    end
  end
end
