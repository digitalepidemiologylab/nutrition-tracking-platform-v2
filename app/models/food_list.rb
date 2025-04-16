# frozen_string_literal: true

class FoodList < ApplicationRecord
  has_paper_trail

  belongs_to :country, optional: true
  has_many :foods, inverse_of: :food_list, dependent: :restrict_with_error
  has_many :cohort_food_lists, inverse_of: :food_list, dependent: :restrict_with_error
  has_many :cohorts, through: :cohort_food_lists

  validates :name, presence: true, uniqueness: {case_sensitive: false, allow_blank: true}
  validate :no_setter_errors

  def metadata_data=(metadata_data)
    self.metadata = metadata_data.blank? ? {} : JSON.parse(metadata_data)
  rescue JSON::ParserError
    self.metadata = {}
    @setter_errors ||= {}
    @setter_errors[:metadata_data] = :invalid
    @metadata_with_errors = metadata_data
  end

  def metadata_data
    @metadata_with_errors || metadata.to_json
  end

  private def no_setter_errors
    return if @setter_errors.blank?

    @setter_errors.each do |k, v|
      errors.add(k, v)
    end
  end
end
