# frozen_string_literal: true

class SerializablePushToken < JSONAPI::Serializable::Resource
  type "push_tokens"

  has_one :user do
    linkage always: true
  end

  attributes :platform, :token, :locale
end
