# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::V2::IntakePolicy) do
  let(:user) { create(:user) }

  permissions :index? do
    it { expect(described_class).to permit(user, Intake) }
  end

  permissions :create?, :update? do
    let(:dish) { create(:dish, user: user) }
    let!(:intake) { dish.annotations.sole.intakes.sole }
    let!(:other_user_intake) { create(:intake) }

    it do
      expect(described_class).to permit(user, intake)
      expect(described_class).not_to permit(user, other_user_intake)
    end
  end

  permissions :destroy? do
    let(:dish) { create(:dish, user: user) }
    let(:intake) { dish.annotations.sole.intakes.sole }
    let(:other_user) { build(:user) }

    it do
      expect(described_class).to permit(user, intake)
      expect(described_class).not_to permit(other_user, intake)
    end
  end

  describe "#permitted_attributes" do
    let(:intake) { build(:intake) }

    it do
      expect(described_class.new(user, intake).permitted_attributes)
        .to contain_exactly(:id, :type, attributes: %i[consumed_at timezone])
    end
  end

  describe "#permitted_includes" do
    let(:intake) { build(:intake) }

    it do
      expect(described_class.new(user, intake).permitted_includes)
        .to contain_exactly(
          "annotation", "annotation.dish", "annotation.dish.dish_image", "annotation.comments",
          "annotation.annotation_items", "annotation.annotation_items.food", "annotation.annotation_items.product",
          "annotation.annotation_items.product.product_images"
        )
    end
  end

  describe Api::V2::IntakePolicy::Scope do
    let(:dish) { create(:dish, user: user) }
    let!(:intake) { dish.annotations.sole.intakes.sole }

    describe "#resolve" do
      context "when user has intakes" do
        it { expect(described_class.new(user, Intake).resolve).to contain_exactly(intake) }
      end

      context "when user has no intakes" do
        let(:user_without_intake) { create(:user) }

        it { expect(described_class.new(user_without_intake, Intake).resolve).to be_empty }
      end
    end
  end
end
