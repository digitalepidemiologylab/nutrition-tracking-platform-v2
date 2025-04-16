# frozen_string_literal: true

class NoteForm < BaseActiveModelService
  attr_reader :notable, :note

  validate :validate_notable

  def initialize(notable:)
    @notable = notable
    @note = notable.note
  end

  def save(params)
    @note = params.fetch(:note)
    notable.note = note
    return false if invalid?

    notable.save!
  rescue => e
    errors.add(:base, e.message)
    false
  end

  private def validate_notable
    promote_errors(notable) if notable.invalid?
  end
end
