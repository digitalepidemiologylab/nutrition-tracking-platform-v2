# frozen_string_literal: true

class Food < ApplicationRecord
  extend Mobility
  include SearchableByName

  has_paper_trail

  belongs_to :food_list, inverse_of: :foods
  belongs_to :unit, inverse_of: :foods
  has_many :annotation_items, inverse_of: :food, dependent: :restrict_with_error
  has_many :food_food_sets, dependent: :destroy, inverse_of: :food
  has_many :food_nutrients, inverse_of: :food, dependent: :destroy
  has_many :food_sets, through: :food_food_sets

  translates :name, dirty: true

  validates :name_en, presence: true
  validates :name, uniqueness: {allow_blank: true, case_sensitive: false, scope: :food_list_id}

  accepts_nested_attributes_for :food_nutrients, allow_destroy: true
  validates_associated :food_nutrients

  scope :of_food_lists, ->(food_lists) {
    where(food_list: food_lists)
  }

  scope :order_by_annotation_count, ->(dir) {
    left_joins(:annotation_items)
      .i18n
      .group("foods.id, food_translations_en.name")
      .order(Arel.sql(ActiveRecord::Base.sanitize_sql_for_order("count(annotation_items.id) #{dir}")))
      .order(:name)
  }
end
