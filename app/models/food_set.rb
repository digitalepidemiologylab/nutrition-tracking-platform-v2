# frozen_string_literal: true

class FoodSet < ApplicationRecord
  extend Mobility
  include SearchableByName

  has_paper_trail

  has_many :annotation_items, inverse_of: :food_set, dependent: :restrict_with_error
  has_many :food_food_sets, inverse_of: :food_set, dependent: :destroy
  has_many :foods, through: :food_food_sets

  translates :name, dirty: true

  validates :name, presence: true, uniqueness: {allow_blank: true, case_sensitive: false}
  validates :cname, codename: true, presence: true, uniqueness: {allow_blank: true}

  before_validation :set_cname

  private def set_cname
    return if cname.present?

    self.cname = name_en&.parameterize&.underscore&.downcase
  end
end
