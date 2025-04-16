# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe("api/v2/dish_forms", :freeze_swagger_time) do
  let!(:user) { create(:user, :with_participation, id: "e1b7308e-40d6-41ad-a7b6-f729cbfe3021") }
  let(:body) { JSON.parse(response.body) }

  before do
    create_base_units
    api_sign_in(user)
  end

  describe "create" do
    path "/api/v2/dish_forms" do
      post("create a dish") do
        tags "Dishes"
        set_http_headers
        parameter name: :include, in: :query, type: :string,
          description: include_param_description(Api::V2::DishFormPolicy)
        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                type: {type: :string, enum: %w[dish_forms]},
                attributes: {
                  type: :object,
                  properties: {
                    dish: {
                      type: :object,
                      properties: {
                        id: {type: :string, format: :uuid},
                        description: {type: :string}
                      }
                    },
                    intake: {
                      type: :object,
                      properties: {
                        id: {type: :string, format: :uuid},
                        consumed_at: {type: :string, format: "date-time"},
                        timezone: {type: :string, enum: ["Asia/Hong_Kong", "Etc/UTC"]}
                      }
                    },
                    dish_image: {
                      type: :object,
                      properties: {
                        data: {type: :string, enum: ["DirectUpload signed_id"]}
                      }
                    },
                    product: {
                      type: :object,
                      properties: {
                        barcode: {type: :string}
                      }
                    },
                    product_images: {
                      type: :array,
                      items: {
                        properties: {
                          data: {type: :string, enum: ["DirectUpload signed_id"]}
                        }
                      }
                    }
                  }
                }
              },
              required: %w[attributes]
            }
          },
          required: %w[data]
        }
        let(:include) { "annotation.dish.dish_image" }
        let(:dish_image_direct_upload) { create(:direct_upload, :with_dish_image_uploaded) }
        let(:product_image_direct_upload) { create(:direct_upload, :with_product_image_uploaded) }
        let(:data) {
          {
            data: {
              type: "dish_forms",
              attributes: {
                dish: {
                  id: "a603c509-5ca7-42d8-a888-90a5b97dab4e",
                  description: "Test description"
                },
                intake: {
                  id: "12d58ade-c5c6-4589-955e-28c7a62ca73f",
                  consumed_at: Time.current.iso8601,
                  timezone: "Asia/Hong_Kong"
                },
                dish_image: {
                  data: dish_image_direct_upload.signed_id
                },
                product: {
                  barcode: "5449000009500"
                },
                product_images: [
                  {data: product_image_direct_upload.signed_id}
                ]
              }
            }
          }
        }

        context "when successful" do
          response(200, "OK") do
            run_test! do |response|
              expect(body["data"].keys)
                .to contain_exactly("id", "relationships", "type")
              expect(body["included"].count { |i| i["type"] == "dish_images" }).to eq(1)
            end
          end
        end

        context "when failed" do
          before do
            allow_any_instance_of(DishForm).to receive(:save).and_return(false)
            allow_any_instance_of(DishForm).to receive(:errors)
              .and_return(ActiveModel::Errors.new(DishImage.new).tap { |e|
                            e.add(:base, "Dish image data is not an image")
                          })
          end

          response(422, "Unprocessable Entity") do
            run_test! do |response|
              expect(body)
                .to eq(
                  {
                    "errors" => [
                      {
                        "detail" => "Dish image data is not an image",
                        "source" => {},
                        "title" => "Invalid base"
                      }
                    ],
                    "jsonapi" => {"version" => "1.0"}
                  }
                )
            end
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup
