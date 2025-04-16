# frozen_string_literal: true

class CohortFoodList < ApplicationRecord
  has_paper_trail

  belongs_to :cohort, inverse_of: :cohort_food_lists
  belongs_to :food_list, inverse_of: :cohort_food_lists
end
