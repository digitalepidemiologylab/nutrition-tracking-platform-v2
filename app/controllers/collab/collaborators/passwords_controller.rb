# frozen_string_literal: true

module Collab
  module Collaborators
    class PasswordsController < Devise::PasswordsController
      include HasLocale
    end
  end
end
