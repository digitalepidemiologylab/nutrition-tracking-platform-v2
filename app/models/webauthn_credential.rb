# frozen_string_literal: true

class WebauthnCredential < ApplicationRecord
  belongs_to :collaborator, inverse_of: :webauthn_credentials

  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :nickname, presence: true, uniqueness: {scope: :collaborator_id}
  validates :sign_count, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
end
