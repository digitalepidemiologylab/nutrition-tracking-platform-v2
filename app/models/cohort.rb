# frozen_string_literal: true

class Cohort < ApplicationRecord
  has_paper_trail

  belongs_to :segmentation_client, inverse_of: :cohorts
  has_many :cohort_food_lists, inverse_of: :cohort, dependent: :restrict_with_error
  has_many :food_lists, through: :cohort_food_lists
  has_many :collaborations, inverse_of: :cohort, dependent: :restrict_with_error
  has_many :participations, inverse_of: :cohort, dependent: :restrict_with_error
  has_many :users, through: :participations
  has_many :dishes, through: :users

  validates :name, presence: true
end
