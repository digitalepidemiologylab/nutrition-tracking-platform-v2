# frozen_string_literal: true

class SegmentationClient < ApplicationRecord
  has_many :cohorts, inverse_of: :segmentation_client, dependent: :restrict_with_error
  has_many :polygon_sets, inverse_of: :segmentation_client, dependent: :destroy
  has_many :segmentations, inverse_of: :segmentation_client, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: {allow_nil: true}
  validates :ml_model, presence: true, uniqueness: {allow_nil: true}
end
