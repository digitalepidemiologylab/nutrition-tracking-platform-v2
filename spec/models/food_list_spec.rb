# frozen_string_literal: true

require "rails_helper"

describe(FoodList) do
  describe("Associations") do
    let(:food_list) { build(:food_list) }

    it do
      expect(food_list).to(belong_to(:country).optional)
      expect(food_list).to(have_many(:foods).inverse_of(:food_list).dependent(:restrict_with_error))
      expect(food_list).to(have_many(:cohort_food_lists).inverse_of(:food_list).dependent(:restrict_with_error))
      expect(food_list).to(have_many(:cohorts).through(:cohort_food_lists))
    end
  end

  describe("Validations") do
    let(:food_list) { create(:food_list) }

    describe("name") do
      it do
        expect(food_list).to(validate_presence_of(:name))
        expect(food_list).to(validate_uniqueness_of(:name).case_insensitive)
      end
    end
  end

  describe("#metadata_data=(metadata_data)") do
    let(:food_list) { build(:food_list, metadata_data: metadata_data) }

    before do
      food_list.validate
    end

    context("when metadata_data is blank") do
      let(:metadata_data) { "" }

      it do
        expect(food_list.metadata).to(eq({}))
      end
    end

    context("when metadata_data is invalid JSON") do
      let(:metadata_data) { "invalid" }

      it do
        expect(food_list.metadata).to(eq({}))
        expect(food_list.errors[:metadata_data]).to(eq(["is not valid JSON"]))
      end
    end

    context("when metadata_data is valid JSON") do
      let(:metadata_data) { '{"a": 1}' }

      it do
        expect(food_list.metadata).to(eq("a" => 1))
      end
    end
  end

  describe("#metadata_data") do
    let(:food_list) { build(:food_list, metadata: metadata) }

    context("when metadata is empty") do
      let(:metadata) { {} }

      it do
        expect(food_list.metadata_data).to(eq("{}"))
      end
    end

    context("when metadata is not empty") do
      let(:metadata) { {"a" => 1} }

      it do
        expect(food_list.metadata_data).to(eq('{"a":1}'))
      end
    end
  end
end
