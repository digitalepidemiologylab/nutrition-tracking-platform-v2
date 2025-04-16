# frozen_string_literal: true

FactoryBot.define do
  factory :direct_upload, class: "ActiveStorage::Blob" do
    filename { "filename" }
    content_type { "image/jpeg" }
    byte_size { 1234 }
    checksum { "checksum" }

    trait :with_dish_image_uploaded do
      after :create do |direct_upload|
        direct_upload.upload(File.open(Rails.root.glob("spec/fixtures/images/dishes/*.jpg").sample))
      end
    end

    trait :with_product_image_uploaded do
      after :create do |direct_upload|
        direct_upload.upload(File.open(Rails.root.glob("spec/fixtures/images/products/*.jpg").sample))
      end
    end
  end
end
