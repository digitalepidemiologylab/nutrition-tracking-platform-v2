# frozen_string_literal: true

class Collaborator < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :validatable, :lockable, :trackable

  include DeviseTokenAuth::Concerns::User
  include HasTimezone
  include HasPasswordNotPwned

  has_many :collaborations, inverse_of: :collaborator, dependent: :destroy
  has_many :comments, inverse_of: :collaborator, dependent: :restrict_with_error
  has_many :webauthn_credentials, inverse_of: :collaborator, dependent: :destroy

  validates :name, presence: true, if: ->(c) { c.invitation_token.blank? }
  validates :admin, inclusion: {in: [true, false]}
  validates :webauthn_id, uniqueness: {allow_nil: true}

  before_validation :set_session_token

  accepts_nested_attributes_for :collaborations

  # Currently, Devises uses the hashed password to generate the salt, that means the only way to invalidate the session
  # would be to change the password. Alternative => add a new hash that we can easily change everytime the user logs out
  # see https://github.com/heartcombo/devise/blob/master/lib/devise/models/database_authenticatable.rb#L176
  def authenticatable_salt
    "#{super}.#{session_token}"
  end

  def reset_session_token
    self.session_token = SecureRandom.hex
  end

  private def set_session_token
    return if session_token.present?

    reset_session_token
  end
end
