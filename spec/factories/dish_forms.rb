# frozen_string_literal: true

FactoryBot.define do
  factory :dish_form do
    user factory: %i[user with_participation]
    initialize_with { new(user: user) }
    to_create do |instance|
      product = FactoryBot.create(:product)
      direct_upload_1 = FactoryBot.create(:direct_upload)
      direct_upload_2 = FactoryBot.create(:direct_upload)

      params = {
        type: "dish_forms",
        relationships: {
          dish: {
            data: {
              type: "dishes",
              id: Faker::Internet.uuid,
              attributes: {
                description: "Test description"
              }
            }
          },
          intake: {
            data: {
              type: "intakes",
              attributes: {
                consumed_at: Time.current.iso8601,
                timezone: "Asia/Hong_Kong"
              }
            }
          },
          dish_image: {
            data: {
              type: "dish_images",
              attributes: {
                data: direct_upload_1.signed_id
              }
            }
          },
          product: {
            data: {
              type: "products",
              attributes: {
                barcode: product.barcode
              }
            }
          },
          product_images: {
            data: {
              type: "product_images",
              attributes: [
                {data: direct_upload_2.signed_id}
              ]
            }
          }
        }
      }

      instance.save(params: params)
    end
  end
end
