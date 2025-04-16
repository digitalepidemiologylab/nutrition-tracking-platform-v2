# frozen_string_literal: true

require "rails_helper"

describe CohortFoodList do
  describe("Associations") do
    let(:cohort_food_list) { build(:cohort_food_list) }

    it do
      expect(cohort_food_list)
        .to belong_to(:cohort).inverse_of(:cohort_food_lists)
      expect(cohort_food_list)
        .to belong_to(:food_list).inverse_of(:cohort_food_lists)
    end
  end
end
