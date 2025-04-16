# frozen_string_literal: true

FactoryBot.define do
  factory :dish do
    user

    after(:build) do |dish|
      next if dish.annotations.any?

      dish.annotations << build(:annotation, dish: dish)
    end

    trait :with_description do
      description { Faker::Food.description }
    end

    trait :with_annotation do
      annotations { build_list(:annotation, 1) }
    end

    trait :with_annotations do
      annotations { build_list(:annotation, 2) }
    end

    trait :with_dish_image do
      dish_image
    end

    trait :with_annotation_item do
      annotations { build_list(:annotation, 1, :with_annotation_item) }
    end

    trait :with_annotation_items do
      annotations { build_list(:annotation, 2, :with_annotation_items) }
    end
  end
end
