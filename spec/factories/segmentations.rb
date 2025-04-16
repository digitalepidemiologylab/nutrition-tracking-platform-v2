# frozen_string_literal: true

FactoryBot.define do
  factory :segmentation do
    annotation factory: %i[annotation with_dish_image]
    dish_image { annotation.dish.dish_image }
    segmentation_client

    trait :requested do
      task_id { Faker::Internet.uuid }
      started_at { Time.current }

      after(:build) do |segmentation|
        segmentation.request
      end
    end

    trait :received do
      response_body { {results: [{myfoodrepo_category_id: 1234}]} }
      ai_model { "MFR 0.3" }

      after(:build) do |segmentation|
        # cannot request segmentation if it not saved
        segmentation.save!
        segmentation.request
        segmentation.receive
      end
    end
  end
end
