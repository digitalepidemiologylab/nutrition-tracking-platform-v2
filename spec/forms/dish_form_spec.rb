# frozen_string_literal: true

require "rails_helper"

describe(DishForm) do
  let(:user) { create(:user, :with_participation) }
  let(:barcode) { "5449000009500" }
  let(:description) { "Test description" }
  let(:dish_form) { described_class.new(user: user) }
  let(:dish_uuid) { SecureRandom.uuid }
  let(:dish) { dish_form.dish }
  let(:intake_uuid) { SecureRandom.uuid }
  let(:intake) { dish_form.intake }
  let(:dish_image_direct_upload) { create(:direct_upload, :with_dish_image_uploaded) }
  let(:product_image_direct_upload_1) { create(:direct_upload, :with_product_image_uploaded) }
  let(:product_image_direct_upload_2) { create(:direct_upload, :with_product_image_uploaded) }

  before { create_base_units }

  describe "#save" do
    before { dish_form.save(params: params) }

    context "with valid food params" do
      let(:params) { valid_food_params }

      it do
        dish.reload
        expect(dish).to be_valid
        expect(dish).to be_persisted
        expect(dish.id).to eq(dish_uuid)
        expect(dish.description).to be_nil
        expect(dish.dish_image).to be_valid
        expect(dish.dish_image).to be_persisted
        expect(intake).to be_valid
        expect(intake).to be_persisted
        expect(intake.id).to eq(intake_uuid)
        expect(dish.annotations.size).to eq(1)
        annotation = dish.annotations.first
        expect(annotation).to be_valid
        expect(annotation).to be_persisted
        expect(annotation.annotation_items).to be_empty
        expect(annotation.intakes.size).to eq(1)
        expect(dish_form.product).to be_nil
        expect(dish_form.product_images).to eq([])
      end
    end

    context "with an existing dish id" do
      let(:params) { valid_food_params }
      let(:second_dish_form) { described_class.new(user: user) }
      let(:second_dish_form_params) do
        valid_food_params.tap do |params|
          params[:attributes][:intake].delete(:id)
          params[:attributes].delete(:dish_image)
        end
      end

      it do
        expect { second_dish_form.save(params: second_dish_form_params) }
          .to raise_error(ActiveRecord::RecordNotUnique, "Dish already exists")
      end
    end

    context "with an existing intake id" do
      let(:params) { valid_food_params }
      let(:second_dish_form) { described_class.new(user: user) }
      let(:second_dish_form_params) do
        valid_food_params.tap do |params|
          params[:attributes][:dish].delete(:id)
          params[:attributes].delete(:dish_image)
        end
      end

      it do
        expect { second_dish_form.save(params: second_dish_form_params) }
          .to raise_error(ActiveRecord::RecordNotUnique, "Intake already exists")
      end
    end

    context "with an already attached direct upload id" do
      let(:params) { valid_food_params }
      let(:second_dish_form) { described_class.new(user: user) }
      let(:second_dish_form_params) do
        valid_food_params.tap do |params|
          params[:attributes][:dish].delete(:id)
          params[:attributes][:intake].delete(:id)
        end
      end

      it do
        expect { second_dish_form.save(params: second_dish_form_params) }
          .to raise_error(ActiveRecord::RecordNotUnique, "Dish image already attached")
      end
    end

    context "with valid product params" do
      let(:params) { valid_product_params }

      it do # rubocop:disable RSpec/ExampleLength
        dish.reload
        expect(dish).to be_valid
        expect(dish).to be_persisted
        expect(dish.id).to eq(dish_uuid)
        expect(dish.description).to be_nil
        expect(dish.dish_image).to be_nil
        expect(intake).to be_valid
        expect(intake).to be_persisted
        expect(intake.id).to eq(intake_uuid)
        expect(dish.annotations.size).to eq(1)
        annotation = dish.annotations.first
        expect(annotation).to be_valid
        expect(annotation).to be_persisted
        expect(annotation.annotation_items.size).to eq(1)
        expect(annotation.intakes.size).to eq(1)
        annotation_item = annotation.annotation_items.first
        expect(annotation_item).to be_valid
        expect(annotation_item).to be_persisted
        product = annotation_item.product
        expect(product).to be_valid
        expect(product).to be_persisted
        expect(product.product_images.size).to eq(2)
        product_image = product.product_images.first
        expect(product_image).to be_valid
        expect(product_image).to be_persisted
      end
    end

    context "with valid description params" do
      let(:params) { valid_description_params }

      it do
        dish.reload
        expect(dish).to be_valid
        expect(dish).to be_persisted
        expect(dish.id).to eq(dish_uuid)
        expect(dish.description).to eq(description)
        expect(dish.dish_image).to be_nil
        expect(intake).to be_valid
        expect(intake).to be_persisted
        expect(intake.id).to eq(intake_uuid)
        expect(dish.annotations.size).to eq(1)
        annotation = dish.annotations.first
        expect(annotation).to be_valid
        expect(annotation).to be_persisted
        expect(annotation.annotation_items).to be_empty
        expect(annotation.intakes.size).to eq(1)
        expect(dish_form.product).to be_nil
        expect(dish_form.product_images).to eq([])
      end
    end

    context "with invalid params" do
      let(:params) { invalid_params }

      it do
        expect(dish).not_to be_valid
        expect(dish).not_to be_persisted
        expect(dish.id).to eq(dish_uuid)
        expect(dish.description).to be_nil
        expect(dish.errors.full_messages).to contain_exactly("Dish image data is not an image", "Image is invalid")
        expect(dish.dish_image).not_to be_valid
        expect(dish.dish_image).not_to be_persisted
        expect(intake).to be_valid
        expect(intake).not_to be_persisted
        expect(dish.annotations.size).to eq(1)
        annotation = dish.annotations.first
        expect(annotation).to be_valid
        expect(annotation).not_to be_persisted
        expect(annotation.annotation_items).to be_empty
        expect(annotation.intakes.size).to eq(1)
        expect(dish_form.product).to be_nil
        expect(dish_form.product_images).to eq([])
      end
    end

    context "when user has no current participation" do
      let!(:user) { create(:user) }
      let(:params) { valid_food_params }

      it do
        expect(dish).not_to be_valid
        expect(dish).not_to be_persisted
        expect(dish.id).to eq(dish_uuid)
        expect(dish.description).to be_nil
        expect(dish.errors.full_messages).to contain_exactly("Annotations is invalid")
        expect(dish.dish_image).to be_valid
        expect(dish.dish_image).not_to be_persisted
        expect(intake).to be_valid
        expect(intake).not_to be_persisted
        expect(dish.annotations.size).to eq(1)
        annotation = dish.annotations.first
        expect(annotation).not_to be_valid
        expect(annotation.errors.full_messages).to contain_exactly("Participation must exist")
        expect(annotation).not_to be_persisted
        expect(annotation.annotation_items).to be_empty
        expect(annotation.intakes.size).to eq(1)
        expect(dish_form.product).to be_nil
        expect(dish_form.product_images).to eq([])
      end
    end
  end

  private def valid_food_params
    {
      type: "dish_forms",
      attributes: {
        dish: {
          id: dish_uuid,
          attributes: {
            description: nil
          }
        },
        intake: {
          id: intake_uuid,
          consumed_at: Time.current.iso8601,
          timezone: "Asia/Hong_Kong"
        },
        dish_image: {
          data: dish_image_direct_upload.signed_id
        }
      }
    }
  end

  private def valid_product_params
    {
      type: "dish_forms",
      attributes: {
        dish: {
          id: dish_uuid,
          attributes: {
            description: nil
          }
        },
        intake: {
          id: intake_uuid,
          consumed_at: Time.current.iso8601,
          timezone: "America/New_York"
        },
        product: {
          barcode: barcode
        },
        product_images: [
          {data: product_image_direct_upload_1.signed_id},
          {data: product_image_direct_upload_2.signed_id}
        ]
      }
    }
  end

  private def valid_description_params
    {
      type: "dish_forms",
      attributes: {
        dish: {
          id: dish_uuid,
          attributes: {
            description: description
          }
        },
        intake: {
          id: intake_uuid,
          consumed_at: Time.current.iso8601,
          timezone: "Europe/Berlin"
        }
      }
    }
  end

  private def invalid_params
    valid_food_params.deep_merge(
      attributes: {
        dish_image: {
          data: "bad_signed_id"
        }
      }
    )
  end
end
