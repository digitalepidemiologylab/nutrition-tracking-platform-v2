# frozen_string_literal: true

module HasNote
  extend ActiveSupport::Concern

  MAX_NOTE_LENGTH = 280

  included do
    validates :note, length: {maximum: MAX_NOTE_LENGTH}
  end
end
