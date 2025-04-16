# frozen_string_literal: true

class PushToken < ApplicationRecord
  enum platform: {android: "android", ios: "ios"}

  belongs_to :user, inverse_of: :push_tokens
  has_many :push_notifications, inverse_of: :push_token, dependent: :nullify

  validates :locale, presence: true, inclusion: {in: I18n.available_locales.map(&:to_s), allow_nil: true}
  validates :platform, inclusion: {in: platforms.keys}
  validates :token, presence: true, uniqueness: {allow_nil: true, case_sensitive: false, conditions: -> { active }, if: -> { deactivated_at.nil? }}

  scope :active, -> { where(deactivated_at: nil) }

  def platform_ios?
    platform == "ios"
  end

  def platform_android?
    platform == "android"
  end

  def deactivate
    update(deactivated_at: Time.current)
  end

  def deactivate!
    update!(deactivated_at: Time.current)
  end

  def deactivated?
    deactivated_at.present?
  end
end
