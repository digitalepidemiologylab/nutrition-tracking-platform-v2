# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::FoodNutrientsController) do
  let(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:food) { create(:food, :editable, food_nutrients: [build(:food_nutrient, nutrient: nutrient_kcal)]) }
  let!(:nutrient_kcal) { create(:nutrient, id: "energy_kcal", unit: create(:unit, :energy)) }
  let!(:nutrient_kj) { create(:nutrient, id: "energy_kj", unit: create(:unit, :energy)) }

  before do
    sign_in(collaborator_admin)
  end

  describe "#new" do
    context "when successful" do
      context "when food_id is present" do
        let(:request) { get(new_collab_food_nutrient_path(food_id: food.id), headers: turbo_stream_headers) }

        it do
          request
          expect(response.body).to match("<turbo-stream action=\"append\"")
          expect(response.body).not_to match(nutrient_kcal.name)
          expect(response.body).to match(nutrient_kj.name)
        end
      end

      context "when food_id is not passed" do
        let(:request) { get(new_collab_food_nutrient_path, headers: turbo_stream_headers) }

        it do
          request
          expect(response.body).to match("<turbo-stream action=\"append\"")
          expect(response.body).to match(nutrient_kcal.name)
          expect(response.body).to match(nutrient_kj.name)
        end
      end
    end
  end
end
