# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::DishFormPolicy) do
  let(:user) { build(:user) }
  let(:user_2) { build(:user) }
  let(:dish_form) { build(:dish_form, user: user) }
  let(:policy) { described_class }

  permissions :create? do
    context "when dish user == current_user" do
      it { expect(policy).to permit(user, dish_form) }
      it { expect(policy).not_to permit(user_2, dish_form) }
    end
  end

  describe "#permitted_attributes" do
    it do
      expect(described_class.new(user, dish_form).permitted_attributes)
        .to contain_exactly(
          :type,
          {
            attributes: {
              dish: %i[id description],
              dish_image: :data,
              intake: %i[id consumed_at timezone],
              product: :barcode,
              product_images: [
                [:data]
              ]
            }
          }
        )
    end
  end

  describe "#permitted_includes" do
    it do
      expect(described_class.new(user, dish_form).permitted_includes)
        .to contain_exactly(
          "annotation", "annotation.intakes", "annotation.dish", "annotation.dish.dish_image", "annotation.comments",
          "annotation.annotation_items", "annotation.annotation_items.food", "annotation.annotation_items.product",
          "annotation.annotation_items.product.product_images"
        )
    end
  end
end
