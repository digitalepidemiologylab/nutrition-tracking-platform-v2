# frozen_string_literal: true

FactoryBot.define do
  factory :dish_image do
    dish
    data do
      dish_image_path = Rails.root.glob("spec/fixtures/images/dishes/*.jpg").sample
      Rack::Test::UploadedFile.new(dish_image_path)
    end

    trait :image_1 do
      data do
        dish_image_path = Rails.root.glob("spec/fixtures/images/dishes/salad.jpg").sample
        Rack::Test::UploadedFile.new(dish_image_path)
      end
    end

    trait :image_2 do
      data do
        dish_image_path = Rails.root.glob("spec/fixtures/images/dishes/burger.jpg").sample
        Rack::Test::UploadedFile.new(dish_image_path)
      end
    end
  end
end
