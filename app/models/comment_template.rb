# frozen_string_literal: true

class CommentTemplate < ApplicationRecord
  extend Mobility

  translates :title, :message, dirty: true

  validates :title, presence: true
  validates :message, presence: true
end
