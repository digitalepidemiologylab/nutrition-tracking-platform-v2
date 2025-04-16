# frozen_string_literal: true

FactoryBot.define do
  factory :product_image do
    product
    data do
      dish_image_path = Rails.root.glob("spec/fixtures/images/products/*.jpg").sample
      Rack::Test::UploadedFile.new(dish_image_path)
    end

    trait :image_1 do
      data do
        dish_image_path = Rails.root.glob("spec/fixtures/images/products/brot.jpg").sample
        Rack::Test::UploadedFile.new(dish_image_path)
      end
    end

    trait :image_2 do
      data do
        dish_image_path = Rails.root.glob("spec/fixtures/images/products/kase.jpg").sample
        Rack::Test::UploadedFile.new(dish_image_path)
      end
    end
  end
end
