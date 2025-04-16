# frozen_string_literal: true

class Country < ApplicationRecord
  extend Mobility

  self.implicit_order_column = :id

  has_many :food_lists, inverse_of: :country, dependent: :restrict_with_error

  translates :name

  validates :id, uniqueness: {case_sensitive: false}, length: {is: 2}

  def id=(id)
    self[:id] = id&.upcase
  end
end
