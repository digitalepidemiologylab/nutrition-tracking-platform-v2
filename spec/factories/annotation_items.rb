# frozen_string_literal: true

FactoryBot.define do
  factory :annotation_item do
    annotation
    food do
      if annotation&.participation&.cohort&.food_lists&.any?
        build(:food, food_list: annotation.participation.cohort.food_lists.first)
      else
        build(:food)
      end
    end
    product { nil }
    original_food_set { food_set }

    # We force the creation of the associated unit as in most cases it
    # simply loads the already existing unit from the DB
    present_unit factory: :unit, strategy: :create

    # We force the creation of the associated unit as in most cases it
    # simply loads the already existing unit from the DB
    consumed_unit factory: :unit, strategy: :create

    trait :with_product do
      food { nil }
      product
    end

    trait :with_polygon_set do
      polygon_set
    end
  end
end
