# frozen_string_literal: true

class User < ApplicationRecord
  include HasNote
  include HasPasswordNotPwned

  ANONYMOUS_DOMAIN = "anonymous.myfoodrepo.org"

  has_paper_trail on: %i[update destroy], only: %i[note], skip: -> { new.attributes.keys - %w[note] }

  devise :database_authenticatable, :registerable, :recoverable, :validatable

  # Must be included after call to `devise``
  include DeviseTokenAuth::Concerns::User

  has_many :dishes, inverse_of: :user, dependent: :destroy
  has_many :annotations, through: :dishes
  has_many :intakes, through: :annotations
  has_many :participations, inverse_of: :user, dependent: :destroy
  has_many :push_tokens, inverse_of: :user, dependent: :destroy
  has_many :cohorts, through: :participations
  has_many :comments, inverse_of: :user, dependent: :destroy

  validates :email, presence: true, uniqueness: {case_sensitive: false}
  validates :dishes_private, inclusion: {in: [true, false]}
  validate :validate_anonymous_user_attributes, on: :update

  def current_participation
    participations
      .where(":now BETWEEN started_at AND COALESCE(ended_at, 'infinity')", now: Time.current)
      .order(:created_at)
      .last
  end

  def email_or_id
    anonymous? ? id : email
  end

  # This checks that anonymous users change both their email and password at the same time
  private def validate_anonymous_user_attributes
    return unless will_save_change_to_anonymous?(from: true, to: false)

    return if will_save_change_to_attribute?(:email) &&
      will_save_change_to_attribute?(:encrypted_password)

    errors.add(:base, I18n.t("activerecord.errors.models.user.email_and_password"))
  end
end
