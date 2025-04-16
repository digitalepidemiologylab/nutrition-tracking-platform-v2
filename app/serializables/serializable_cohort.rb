# frozen_string_literal: true

class SerializableCohort < JSONAPI::Serializable::Resource
  type "cohorts"

  attribute :name

  belongs_to :food_lists do
    linkage always: true
  end

  has_many :participations do
    linkage always: true
  end
end
