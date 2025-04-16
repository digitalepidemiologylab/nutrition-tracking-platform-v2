# frozen_string_literal: true

class SerializableParticipation < JSONAPI::Serializable::Resource
  type "participations"

  belongs_to :cohort do
    linkage always: true
  end

  has_many :annotations do
    linkage always: true
  end

  attribute :key
  attribute(:started_at) { @object&.started_at&.iso8601(6) }
  attribute(:ended_at) { @object&.ended_at&.iso8601(6) }
end
