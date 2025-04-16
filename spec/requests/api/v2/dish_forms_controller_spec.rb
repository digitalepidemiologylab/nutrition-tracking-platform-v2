# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::DishFormsController) do
  let(:user) { create(:user, :with_participation, password: "password") }
  let(:dish_form) { build(:dish_form, user: user) }
  let(:dish_image_direct_upload) { create(:direct_upload, :with_dish_image_uploaded) }
  let(:product_image_direct_upload) { create(:direct_upload, :with_product_image_uploaded) }
  let(:params) {
    {
      data: {
        type: "dish_forms",
        attributes: {
          dish: {
            id: "7bd33f49-5470-488a-a932-14211c6216b3",
            description: "Test description"
          },
          intake: {
            id: "41c0d367-ab5f-459e-92b6-120d46a81582",
            consumed_at: Time.current.iso8601,
            timezone: "Asia/Hong_Kong"
          },
          dish_image: {
            data: dish_image_direct_upload.signed_id
          },
          product: {
            barcode: 5449000009500
          },
          product_images: [
            {data: product_image_direct_upload.signed_id}
          ]
        }
      }
    }.to_json
  }

  before do
    create_base_units
    api_sign_in(user)
  end

  describe "#create" do
    context "when successful" do
      it do
        post api_v2_dish_forms_path(include: "annotation,annotation.intakes,annotation.dish,annotation.comments"),
          params: params,
          headers: auth_params
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        json_data = json["data"]
        expect(json_data.keys).to contain_exactly("id", "relationships", "type")
        expect(json_data["relationships"].keys).to contain_exactly("annotation", "dish", "dish_image", "intake", "product", "product_images")
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

      it do
        post api_v2_dish_forms_path(include: "dish,dish_image,intake"), params: {}, headers: auth_params
        expect(JSON.parse(response.body))
          .to eq(
            "errors" => [
              {
                "detail" => "Dish image data is not an image",
                "source" => {},
                "title" => "Invalid base"
              }
            ],
            "jsonapi" => {
              "version" => "1.0"
            }
          )
      end
    end
  end
end
