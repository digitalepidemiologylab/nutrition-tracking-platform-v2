# frozen_string_literal: true

FactoryBot.define do
  factory :cohort do
    name { Faker::Company.name }
    segmentation_client

    trait :with_food_list do
      food_lists { [build(:food_list)] }
    end
  end
end
