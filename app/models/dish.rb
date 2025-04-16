# frozen_string_literal: true

class Dish < ApplicationRecord
  has_paper_trail on: %i[destroy]

  belongs_to :user, inverse_of: :dishes
  has_many :annotations, inverse_of: :dish, dependent: :destroy
  has_many :annotation_items, through: :annotations
  has_many :participations, through: :user
  has_one :dish_image, inverse_of: :dish, dependent: :destroy

  accepts_nested_attributes_for :dish_image

  validates :id, uniqueness: {case_sensitive: false}
  validates :private, inclusion: {in: [true, false]}
  validates :annotations, presence: true

  validates_associated :dish_image, on: :create
  validates_associated :annotation_items, on: :create

  before_validation :set_private, on: :create

  def has_image?
    dish_image&.data&.attached? || false
  end

  private def set_private
    self.private = !!user&.dishes_private
  end
end
